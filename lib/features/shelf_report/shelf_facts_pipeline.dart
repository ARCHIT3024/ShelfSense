/// Shared first half of the visit pipeline (TRD §4):
///   detections → FacingCounter → PlanogramDiff → shelf_facts (persisted)
///
/// Used by both `/shelf` (to render the table) and `/order` (as input to
/// ReorderEngine) so the two screens can never disagree.
library;

import 'package:drift/drift.dart' as drift;

import '../../core/logger.dart';
import '../../core/result.dart';
import '../../data/db/database.dart' hide ShelfFact;
import '../../domain/models/models.dart';
import '../../domain/services/facing_counter.dart';
import '../../domain/services/planogram_diff.dart';

const _tag = 'ShelfFacts';

class ShelfReport {
  const ShelfReport({required this.facts, required this.skus});

  /// Sorted stockout → below_plan → unlisted → in_stock, then by name.
  final List<ShelfFact> facts;
  final Map<String, Sku> skus;

  int countOf(ShelfStatus s) => facts.where((f) => f.status == s).length;
}

/// Computes the shelf facts for [visitId], joins SKU names, persists them
/// (delete-and-reinsert per 05_DATA_SCHEMA §9) and returns them sorted for
/// display. Throws [StateError] if the visit doesn't exist.
Future<ShelfReport> computeShelfFacts(AppDatabase db, String visitId) async {
  final visit = await (db.select(db.visits)..where((t) => t.id.equals(visitId)))
      .getSingleOrNull();
  if (visit == null) throw StateError('Visit $visitId not found');

  final skuRows =
      await (db.select(db.skus)..where((t) => t.isActive.equals(true))).get();
  final skus = {for (final r in skuRows) r.id: skuFromRow(r)};

  final detRows = await (db.select(db.detections)
        ..where((t) => t.visitId.equals(visitId)))
      .get();
  final boxes = detRows.map(matchedBoxFromRow).toList();

  final planRows = await (db.select(db.planogramEntries)
        ..where((t) => t.storeId.equals(visit.storeId)))
      .get();
  final targets = {for (final r in planRows) r.skuId: r.targetFacings};

  var counted = <String, int>{};
  if (boxes.isNotEmpty) {
    switch (const FacingCounter().count(boxes)) {
      case Ok(:final value):
        counted = Map<String, int>.from(value.bySku);
      case Err(:final failure):
        AppLogger.w(_tag, 'FacingCounter: ${failure.message}');
    }
  }

  var facts = <ShelfFact>[];
  if (counted.isNotEmpty || targets.isNotEmpty) {
    switch (const PlanogramDiff()
        .diff(counted: counted, targets: targets, visitId: visitId)) {
      case Ok(:final value):
        facts = [
          for (final f in value)
            ShelfFact(
              id: f.id,
              visitId: f.visitId,
              skuId: f.skuId,
              skuName: skus[f.skuId]?.name,
              skuCode: skus[f.skuId]?.code,
              grammageLabel: skus[f.skuId]?.grammageLabel,
              detectedFacings: f.detectedFacings,
              targetFacings: f.targetFacings,
              status: f.status,
              computedAt: f.computedAt,
            ),
        ];
        await _persist(db, visitId, facts);
      case Err(:final failure):
        AppLogger.w(_tag, 'PlanogramDiff: ${failure.message}');
    }
  }

  facts.sort((a, b) {
    final s = _rank(a.status).compareTo(_rank(b.status));
    if (s != 0) return s;
    return (a.skuName ?? '').compareTo(b.skuName ?? '');
  });
  return ShelfReport(facts: facts, skus: skus);
}

int _rank(ShelfStatus s) => switch (s) {
      ShelfStatus.stockout => 0,
      ShelfStatus.belowPlan => 1,
      ShelfStatus.unlisted => 2,
      ShelfStatus.inStock => 3,
    };

Future<void> _persist(
    AppDatabase db, String visitId, List<ShelfFact> facts) async {
  await db.transaction(() async {
    await (db.delete(db.shelfFacts)..where((t) => t.visitId.equals(visitId)))
        .go();
    await db.batch((b) {
      for (final f in facts) {
        b.insert(
          db.shelfFacts,
          ShelfFactsCompanion.insert(
            id: f.id,
            visitId: f.visitId,
            skuId: f.skuId,
            detectedFacings: f.detectedFacings,
            targetFacings: f.targetFacings,
            status: f.status.name,
            computedAt: f.computedAt,
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }
    });
  });
}

// ---------------------------------------------------------------------------
// DB row → domain model mappers (shared with order_provider.dart)
// ---------------------------------------------------------------------------

Sku skuFromRow(SkusData r) => Sku(
      id: r.id,
      code: r.code,
      name: r.name,
      brand: r.brand,
      category: r.category,
      grammageValue: r.grammageValue,
      grammageUnit: r.grammageUnit,
      variant: r.variant,
      mrpPaise: r.mrpPaise,
      caseSize: r.caseSize,
      isEnrolled: r.isEnrolled,
      isActive: r.isActive,
      createdAt: r.createdAt,
    );

MatchedBox matchedBoxFromRow(Detection r) => MatchedBox(
      id: r.id,
      box: RawBox(
        x1: r.x1,
        y1: r.y1,
        x2: r.x2,
        y2: r.y2,
        score: r.detConfidence,
      ),
      detConfidence: r.detConfidence,
      skuId: r.skuId,
      matchConfidence: r.matchConfidence,
      method: _methodFromDb(r.matchMethod),
      shelfRow: r.shelfRow,
      isGap: r.isGap,
      wasCorrected: r.wasCorrected,
    );

/// DB stores snake_case (`ocr_tiebreak`), the enum is camelCase.
MatchMethod _methodFromDb(String s) => switch (s) {
      'embedding' => MatchMethod.embedding,
      'ocr_tiebreak' || 'ocrTiebreak' => MatchMethod.ocrTiebreak,
      'manual' => MatchMethod.manual,
      _ => MatchMethod.unmatched,
    };
