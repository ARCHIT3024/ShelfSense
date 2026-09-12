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
import '../../domain/services/reorder_engine.dart';
import '../../ml/llm/deterministic_visit_record.dart';
import '../../output/csv_builder.dart';
import '../../output/xlsx_builder.dart';
import '../shelf_report/shelf_facts_pipeline.dart';

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

  /// "+ Add line" — something the owner asked for that isn't on the shelf.
  /// Starts at one case, flagged as an override (suggested 0) so it carries
  /// the marker and writes an override_events row on confirm.
  void addLine(SkusData sku) {
    final current = state.value;
    if (current == null) return;
    if (current.lines.any((l) => l.skuId == sku.id)) return; // already drafted

    final qty = sku.caseSize < 1 ? 1 : sku.caseSize;
    final line = OrderLine(
      id: _uuid.v4(),
      visitId: _visitId,
      skuId: sku.id,
      skuName: sku.name,
      skuCode: sku.code,
      grammageLabel: _grammage(sku),
      mrpPaise: sku.mrpPaise,
      caseSize: sku.caseSize,
      suggestedQty: 0,
      finalQty: qty,
      unit: 'unit',
      valuePaise: qty * sku.mrpPaise,
      wasOverridden: true,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = AsyncData(current.copyWith(lines: [...current.lines, line]));
  }

  /// Store/beat metadata for the export header is resolved from the visit
  /// here rather than passed by the caller, so it can never be a placeholder.
  Future<void> confirmOrder() async {
    final current = state.value;
    if (current == null || !current.hasLines) return;

    state = AsyncData(current.copyWith(isLoading: true, error: null));

    try {
      final db = ref.read(dbProvider);
      final visit = await (db.select(db.visits)
            ..where((t) => t.id.equals(_visitId)))
          .getSingle();
      final store = await (db.select(db.stores)
            ..where((t) => t.id.equals(visit.storeId)))
          .getSingleOrNull();
      final beat = await (db.select(db.beats)
            ..where((t) => t.id.equals(visit.beatId)))
          .getSingleOrNull();
      final storeCode = store?.code ?? visit.storeId;
      final storeName = store?.name ?? 'Unknown store';
      final beatName = beat?.name ?? visit.beatId;

      await _persistOrderLines(db, current.lines);
      await _persistVisitRecord(db, current.lines);

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

    // FacingCounter → PlanogramDiff → shelf_facts, shared with /shelf.
    final report = await computeShelfFacts(db, _visitId);
    final skus = report.skus.values.toList();

    final trailingQty = await _computeTrailingQty(
        db, visit.storeId, report.skus.keys.toList());

    // ReorderEngine
    final r = const ReorderEngine().suggest(
      facts: report.facts,
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

  /// Deterministic summary + rationale (TRD §5.5 rule 5). `llm_model_id`
  /// stays null ⇒ "no model was involved", per the schema comment. The LLM
  /// (T-23/T-26) may later overwrite the two free-text columns only.
  Future<void> _persistVisitRecord(
      AppDatabase db, List<OrderLine> lines) async {
    final skuRows = await db.select(db.skus).get();
    final skus = {for (final r in skuRows) r.id: r};
    final factRows = await (db.select(db.shelfFacts)
          ..where((t) => t.visitId.equals(_visitId)))
        .get();
    final facts = [
      for (final f in factRows)
        ShelfFact(
          id: f.id,
          visitId: f.visitId,
          skuId: f.skuId,
          skuName: skus[f.skuId]?.name,
          skuCode: skus[f.skuId]?.code,
          detectedFacings: f.detectedFacings,
          targetFacings: f.targetFacings,
          status: ShelfStatus.values.firstWhere(
            (s) => s.name == f.status,
            orElse: () => ShelfStatus.unlisted,
          ),
          computedAt: f.computedAt,
        ),
    ];
    final visit = await (db.select(db.visits)
          ..where((t) => t.id.equals(_visitId)))
        .getSingleOrNull();
    final rec = const DeterministicVisitRecordService().record(
      shelfFacts: facts,
      lines: lines,
      transcript: visit?.noteTranscript,
    );
    await (db.update(db.visits)..where((t) => t.id.equals(_visitId)))
        .write(VisitsCompanion(
      llmSummary: drift.Value(rec.summaryProse),
      llmRationale: drift.Value(rec.reorderRationale),
      llmModelId: const drift.Value(null),
    ));
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
// Provider (AsyncNotifierProvider.family — Riverpod 3.x)
// ---------------------------------------------------------------------------

final orderProvider =
    AsyncNotifierProvider.family<OrderNotifier, OrderState, String>(
  OrderNotifier.new,
);

String _grammage(SkusData s) {
  final v = s.grammageValue;
  if (v == null) return '';
  final disp = v == v.floorToDouble() ? v.toInt().toString() : v.toString();
  return '$disp ${s.grammageUnit ?? ''}'.trim();
}
