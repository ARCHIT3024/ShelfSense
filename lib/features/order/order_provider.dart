/// order_provider.dart — T-19
///
/// Riverpod 3.x provider for the /order screen.
///
/// Full pipeline (pure Dart, zero network):
///   DB → MatchedBox list → FacingCounter → PlanogramDiff
///   → (persist shelf_facts) → ReorderEngine → OrderState
///
/// Pattern: AsyncNotifierProvider.family so the rep can edit finalQty locally
/// before committing to Drift on confirmOrder().
library;

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Hide Drift-generated row classes that clash with domain models.
import '../../data/db/database.dart' hide ShelfFact, OrderLine;

import '../../app/di.dart';
import '../../core/ids.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../domain/models/models.dart';
import '../../domain/services/facing_counter.dart';
import '../../domain/services/planogram_diff.dart';
import '../../domain/services/reorder_engine.dart';
import '../../output/csv_builder.dart';
import '../../output/xlsx_builder.dart';

const _tag = 'OrderProvider';
const _uuid = Uuid();

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class OrderState {
  const OrderState({
    this.lines = const [],
    this.isLoading = false,
    this.error,
    this.exportXlsxPath,
    this.exportCsvPath,
    this.isConfirmed = false,
  });

  final List<OrderLine> lines;
  final bool isLoading;
  final String? error;
  final String? exportXlsxPath;
  final String? exportCsvPath;
  final bool isConfirmed;

  bool get hasLines => lines.isNotEmpty;
  int get totalValuePaise =>
      lines.fold(0, (s, l) => s + l.finalQty * l.mrpPaise);
  int get overrideCount => lines.where((l) => l.wasOverridden).length;

  OrderState copyWith({
    List<OrderLine>? lines,
    bool? isLoading,
    String? error,
    String? exportXlsxPath,
    String? exportCsvPath,
    bool? isConfirmed,
  }) =>
      OrderState(
        lines: lines ?? this.lines,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        exportXlsxPath: exportXlsxPath ?? this.exportXlsxPath,
        exportCsvPath: exportCsvPath ?? this.exportCsvPath,
        isConfirmed: isConfirmed ?? this.isConfirmed,
      );
}

// ---------------------------------------------------------------------------
// AsyncNotifier
// ---------------------------------------------------------------------------

class OrderNotifier extends AsyncNotifier<OrderState> {
  OrderNotifier(this._visitId);

  final String _visitId;

  // ── Build (runs pipeline once on creation) ────────────────────────────────

  @override
  Future<OrderState> build() async {
    final lines = await _computeOrderDraft();
    return OrderState(lines: lines);
  }

  // ── Public actions ────────────────────────────────────────────────────────

  void overrideQty(String lineId, int newQty) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      lines: current.lines.map((l) {
        if (l.id != lineId) return l;
        return OrderLine(
          id: l.id,
          visitId: l.visitId,
          skuId: l.skuId,
          skuName: l.skuName,
          skuCode: l.skuCode,
          grammageLabel: l.grammageLabel,
          mrpPaise: l.mrpPaise,
          caseSize: l.caseSize,
          suggestedQty: l.suggestedQty,
          finalQty: newQty,
          unit: l.unit,
          valuePaise: (newQty * l.mrpPaise).toInt(),
          wasOverridden: newQty != l.suggestedQty,
          createdAt: l.createdAt,
        );
      }).toList(),
    ));
  }

  Future<void> confirmOrder({
    required String storeCode,
    required String storeName,
    required String beatName,
  }) async {
    final current = state.value;
    if (current == null || !current.hasLines) return;

    state = AsyncData(current.copyWith(isLoading: true, error: null));

    try {
      final db = ref.read(dbProvider);
      await _persistOrderLines(db, current.lines);

      final xlsxResult = await buildOrderXlsx(
        storeCode: storeCode,
        storeName: storeName,
        beatName: beatName,
        lines: current.lines,
      );
      final csvResult = await buildOrderCsv(
        storeCode: storeCode,
        lines: current.lines,
      );

      final xlsxPath = xlsxResult.isOk ? xlsxResult.valueOrNull : null;
      final csvPath = csvResult.isOk ? csvResult.valueOrNull : null;

      final beatId = await _getBeatId(db);
      await db.into(db.exportBatches).insertOnConflictUpdate(
        ExportBatchesCompanion.insert(
          id: _uuid.v4(),
          beatId: beatId,
          visitCount: 1,
          lineCount: current.lines.length,
          totalValuePaise: current.totalValuePaise,
          xlsxPath: drift.Value(xlsxPath),
          csvPath: drift.Value(csvPath),
          pdfPath: const drift.Value(null),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      AppLogger.i(_tag, 'Confirmed $_visitId. XLSX=$xlsxPath CSV=$csvPath');
      state = AsyncData(current.copyWith(
        isLoading: false,
        isConfirmed: true,
        exportXlsxPath: xlsxPath,
        exportCsvPath: csvPath,
      ));
    } catch (e, st) {
      AppLogger.e(_tag, 'confirmOrder failed: $e', e);
      state = AsyncError(e, st);
    }
  }

  // ── Pipeline ──────────────────────────────────────────────────────────────

  Future<List<OrderLine>> _computeOrderDraft() async {
    final db = ref.read(dbProvider);

    final visit = await (db.select(db.visits)
          ..where((t) => t.id.equals(_visitId)))
        .getSingleOrNull();
    if (visit == null) throw StateError('Visit $_visitId not found');

    final skuRows = await (db.select(db.skus)
          ..where((t) => t.isActive.equals(true)))
        .get();
    final skus = skuRows.map(_skuFromRow).toList();
    final skuById = {for (final s in skus) s.id: s};

    final detRows = await (db.select(db.detections)
          ..where((t) => t.visitId.equals(_visitId)))
        .get();
    final boxes = detRows.map(_matchedBoxFromRow).toList();

    final planRows = await (db.select(db.planogramEntries)
          ..where((t) => t.storeId.equals(visit.storeId)))
        .get();
    final targets = {for (final r in planRows) r.skuId: r.targetFacings};

    final trailingQty = await _computeTrailingQty(
        db, visit.storeId, skuById.keys.toList());

    // FacingCounter
    Map<String, int> counted = {};
    if (boxes.isNotEmpty) {
      final r = const FacingCounter().count(boxes);
      if (r.isOk) {
        counted = Map<String, int>.from(r.valueOrNull!.bySku);
      } else {
        AppLogger.w(_tag, 'FacingCounter: ${r.failureOrNull?.message}');
      }
    }

    // PlanogramDiff + persist
    List<ShelfFact> facts = [];
    if (counted.isNotEmpty || targets.isNotEmpty) {
      final r = const PlanogramDiff().diff(
        counted: counted,
        targets: targets,
        visitId: _visitId,
      );
      if (r.isOk) {
        facts = r.valueOrNull!.map((f) {
          final sku = skuById[f.skuId];
          return ShelfFact(
            id: f.id,
            visitId: f.visitId,
            skuId: f.skuId,
            skuName: sku?.name,
            skuCode: sku?.code,
            grammageLabel: sku?.grammageLabel,
            detectedFacings: f.detectedFacings,
            targetFacings: f.targetFacings,
            status: f.status,
            computedAt: f.computedAt,
          );
        }).toList();
        await _persistShelfFacts(db, facts);
      } else {
        AppLogger.w(_tag, 'PlanogramDiff: ${r.failureOrNull?.message}');
      }
    }

    // ReorderEngine
    final r = const ReorderEngine().suggest(
      facts: facts,
      skus: skus,
      visitId: _visitId,
      trailingQty: trailingQty,
    );
    if (r.isErr) {
      throw StateError(r.failureOrNull?.message ?? 'ReorderEngine failed');
    }
    return r.valueOrNull!;
  }

  // ── DB helpers ────────────────────────────────────────────────────────────

  Future<void> _persistShelfFacts(
      AppDatabase db, List<ShelfFact> facts) async {
    await db.transaction(() async {
      await (db.delete(db.shelfFacts)
            ..where((t) => t.visitId.equals(_visitId)))
          .go();
      await db.batch((b) {
        for (final f in facts) {
          b.insert(
            db.shelfFacts,
            ShelfFactsCompanion(
              id: drift.Value(f.id),
              visitId: drift.Value(f.visitId),
              skuId: drift.Value(f.skuId),
              detectedFacings: drift.Value(f.detectedFacings),
              targetFacings: drift.Value(f.targetFacings),
              status: drift.Value(f.status.name),
              computedAt: drift.Value(f.computedAt),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  Future<void> _persistOrderLines(
      AppDatabase db, List<OrderLine> lines) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final visitRow = await (db.select(db.visits)
          ..where((t) => t.id.equals(_visitId)))
        .getSingleOrNull();
    final startedAt = visitRow?.startedAt ?? now;

    await db.transaction(() async {
      await (db.update(db.visits)
            ..where((t) => t.id.equals(_visitId)))
          .write(VisitsCompanion(
        status: const drift.Value('confirmed'),
        confirmedAt: drift.Value(now),
        durationMs: drift.Value(now - startedAt),
      ));

      await db.batch((b) {
        for (final line in lines) {
          b.insert(
            db.orderLines,
            OrderLinesCompanion(
              id: drift.Value(line.id),
              visitId: drift.Value(line.visitId),
              skuId: drift.Value(line.skuId),
              suggestedQty: drift.Value(line.suggestedQty),
              finalQty: drift.Value(line.finalQty),
              unit: drift.Value(line.unit),
              valuePaise: drift.Value(line.finalQty * line.mrpPaise),
              wasOverridden: drift.Value(line.wasOverridden),
              createdAt: drift.Value(line.createdAt),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          if (line.wasOverridden) {
            b.insert(
              db.overrideEvents,
              OverrideEventsCompanion(
                id: drift.Value(newId()),
                visitId: drift.Value(line.visitId),
                entity: const drift.Value('order_line'),
                entityId: drift.Value(line.id),
                field: const drift.Value('final_qty'),
                oldValue: drift.Value(line.suggestedQty.toString()),
                newValue: drift.Value(line.finalQty.toString()),
                createdAt: drift.Value(now),
              ),
            );
          }
        }
      });
    });
  }

  Future<String> _getBeatId(AppDatabase db) async {
    final row = await (db.select(db.visits)
          ..where((t) => t.id.equals(_visitId)))
        .getSingleOrNull();
    return row?.beatId ?? '';
  }

  Future<Map<String, int>> _computeTrailingQty(
      AppDatabase db, String storeId, List<String> skuIds) async {
    final result = <String, int>{};
    for (final skuId in skuIds) {
      final query = db.select(db.orderLines).join([
        drift.innerJoin(
          db.visits,
          db.visits.id.equalsExp(db.orderLines.visitId),
        ),
      ])
        ..where(db.visits.storeId.equals(storeId) &
            db.orderLines.skuId.equals(skuId) &
            db.visits.status.equals('confirmed'))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.visits.confirmedAt,
            mode: drift.OrderingMode.desc,
          )
        ])
        ..limit(3);

      final rows = await query.get();
      if (rows.isNotEmpty) {
        final qtys =
            rows.map((r) => r.readTable(db.orderLines).finalQty).toList();
        result[skuId] = medianOrZero(qtys);
      }
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// DB row → domain model mappers
// ---------------------------------------------------------------------------

Sku _skuFromRow(SkusData r) => Sku(
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

MatchedBox _matchedBoxFromRow(Detection r) => MatchedBox(
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
      method: MatchMethod.values.firstWhere(
        (m) => m.name == r.matchMethod,
        orElse: () => MatchMethod.unmatched,
      ),
      shelfRow: r.shelfRow,
      isGap: r.isGap,
      wasCorrected: r.wasCorrected,
    );

// ---------------------------------------------------------------------------
// Provider (AsyncNotifierProvider.family — Riverpod 3.x)
// ---------------------------------------------------------------------------

final orderProvider =
    AsyncNotifierProvider.family<OrderNotifier, OrderState, String>(
  OrderNotifier.new,
);
