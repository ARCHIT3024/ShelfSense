import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../core/ids.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../data/db/database.dart' hide OrderLine;
import '../../domain/models/models.dart' show OrderLine;
import '../../output/csv_builder.dart';
import '../../output/xlsx_builder.dart';

const _tag = 'ExportScreen';

/// One confirmed visit with everything needed to (re)generate its files.
class _VisitExport {
  const _VisitExport({
    required this.visit,
    required this.store,
    required this.beatName,
    required this.lines,
  });
  final Visit visit;
  final Store? store;
  final String beatName;
  final List<OrderLine> lines;

  int get valuePaise => lines.fold(0, (s, l) => s + l.valuePaise);
  String get storeName => store?.name ?? visit.storeId;
  String get storeCode => store?.code ?? visit.storeId;
}

/// Confirmed visits for the (single seeded) beat, newest first.
final _beatExportProvider =
    FutureProvider.autoDispose<List<_VisitExport>>((ref) async {
  final db = ref.watch(dbProvider);
  final visits = await (db.select(db.visits)
        ..where((t) => t.status.isNotValue('draft'))
        ..orderBy([(t) => drift.OrderingTerm.desc(t.confirmedAt)]))
      .get();
  if (visits.isEmpty) return const [];

  final stores = {for (final s in await db.select(db.stores).get()) s.id: s};
  final beats = {for (final b in await db.select(db.beats).get()) b.id: b};
  final skus = {for (final s in await db.select(db.skus).get()) s.id: s};

  final out = <_VisitExport>[];
  for (final v in visits) {
    final rows = await (db.select(db.orderLines)
          ..where((t) => t.visitId.equals(v.id)))
        .get();
    if (rows.isEmpty) continue;
    final lines = [
      for (final r in rows)
        OrderLine(
          id: r.id,
          visitId: r.visitId,
          skuId: r.skuId,
          skuName: skus[r.skuId]?.name,
          skuCode: skus[r.skuId]?.code,
          grammageLabel: _grammage(skus[r.skuId]),
          mrpPaise: skus[r.skuId]?.mrpPaise ?? 0,
          caseSize: skus[r.skuId]?.caseSize ?? 1,
          suggestedQty: r.suggestedQty,
          finalQty: r.finalQty,
          unit: r.unit,
          valuePaise: r.valuePaise,
          wasOverridden: r.wasOverridden,
          createdAt: r.createdAt,
        ),
    ];
    out.add(_VisitExport(
      visit: v,
      store: stores[v.storeId],
      beatName: beats[v.beatId]?.name ?? v.beatId,
      lines: lines,
    ));
  }
  return out;
});

String _grammage(SkusData? s) {
  final v = s?.grammageValue;
  if (s == null || v == null) return '';
  final disp = v == v.floorToDouble() ? v.toInt().toString() : v.toString();
  return '$disp ${s.grammageUnit ?? ''}'.trim();
}

/// `/export` — beat summary → per-visit XLSX / CSV, generated on the phone.
/// PDF beat summary is the L2 deliverable (T-29) and is not offered yet.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _busy = false;

  Future<List<XFile>> _generate(
      List<_VisitExport> visits, {
      required bool xlsx,
      required bool csv,
    }) async {
    final files = <XFile>[];
    for (final v in visits) {
      if (xlsx) {
        switch (await buildOrderXlsx(
          storeName: v.storeName,
          storeCode: v.storeCode,
          beatName: v.beatName,
          lines: v.lines,
        )) {
          case Ok(:final value):
            files.add(XFile(value,
                mimeType:
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'));
          case Err(:final failure):
            AppLogger.e(_tag, 'XLSX for ${v.storeCode} failed', failure);
        }
      }
      if (csv) {
        switch (await buildOrderCsv(storeCode: v.storeCode, lines: v.lines)) {
          case Ok(:final value):
            files.add(XFile(value, mimeType: 'text/csv'));
          case Err(:final failure):
            AppLogger.e(_tag, 'CSV for ${v.storeCode} failed', failure);
        }
      }
    }
    return files;
  }

  Future<void> _share(List<_VisitExport> visits,
      {required bool xlsx, required bool csv}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final files = await _generate(visits, xlsx: xlsx, csv: csv);
      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nothing to export.')));
        }
        return;
      }
      // Record the batch (05_DATA_SCHEMA §12) when it's the whole beat.
      if (visits.length > 1 || (xlsx && csv)) {
        final db = ref.read(dbProvider);
        await db.into(db.exportBatches).insert(ExportBatchesCompanion.insert(
              id: newId(),
              beatId: visits.first.visit.beatId,
              visitCount: visits.length,
              lineCount: visits.fold(0, (s, v) => s + v.lines.length),
              totalValuePaise: visits.fold(0, (s, v) => s + v.valuePaise),
              xlsxPath: drift.Value(
                  files.where((f) => f.path.endsWith('.xlsx')).map((f) => f.path).join(';')),
              csvPath: drift.Value(
                  files.where((f) => f.path.endsWith('.csv')).map((f) => f.path).join(';')),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ));
      }
      final label = visits.length == 1
          ? '${visits.first.beatName} · ${visits.first.storeName}'
          : '${visits.first.beatName} · ${visits.length} visits';
      await SharePlus.instance.share(ShareParams(files: files, text: label));
    } catch (e) {
      AppLogger.e(_tag, 'Share failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_beatExportProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Export beat')),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
            child: Text('Could not load visits.\n$e',
                style: AppText.body, textAlign: TextAlign.center)),
        data: (visits) => visits.isEmpty
            ? const _Empty()
            : _buildList(visits),
      ),
      bottomNavigationBar: async.whenOrNull(
        data: (visits) => visits.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Sp.screen, Sp.sm, Sp.screen, Sp.lg),
                  child: FilledButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _share(visits, xlsx: true, csv: true),
                    icon: const Icon(Icons.ios_share),
                    label: Text(_busy
                        ? 'Generating…'
                        : 'Generate all · XLSX + CSV'),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildList(List<_VisitExport> visits) {
    final lines = visits.fold(0, (s, v) => s + v.lines.length);
    final value = visits.fold(0, (s, v) => s + v.valuePaise);
    final money = NumberFormat('#,##0');
    return ListView(
      padding: const EdgeInsets.all(Sp.screen),
      children: [
        Text(visits.first.beatName, style: AppText.heading),
        const SizedBox(height: Sp.xs),
        Text(
          '${visits.length} visit${visits.length == 1 ? '' : 's'}'
          '  ·  $lines lines  ·  ₹${money.format(value ~/ 100)}',
          style: AppText.mono.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Sp.lg),
        for (final v in visits) ...[
          Container(
            padding: const EdgeInsets.all(Sp.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Radii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(v.storeName, style: AppText.heading),
                    ),
                    Text('₹${money.format(v.valuePaise ~/ 100)}',
                        style: AppText.mono),
                  ],
                ),
                const SizedBox(height: Sp.xs),
                Text(
                  '${v.storeCode}  ·  ${v.lines.length} lines  ·  '
                  '${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(v.visit.confirmedAt ?? v.visit.startedAt))}',
                  style: AppText.label,
                ),
                const SizedBox(height: Sp.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _share([v], xlsx: true, csv: false),
                        icon: const Icon(Icons.table_chart_outlined, size: 18),
                        label: const Text('XLSX'),
                      ),
                    ),
                    const SizedBox(width: Sp.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _share([v], xlsx: false, csv: true),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('CSV'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.sm),
        ],
        const SizedBox(height: Sp.lg),
        Text(
          'PDF beat summary arrives with the voice-note visit record (L2).',
          style: AppText.label,
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(Sp.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: AppColors.textDisabled),
            SizedBox(height: Sp.lg),
            Text('No confirmed visits yet',
                style: AppText.heading, textAlign: TextAlign.center),
            SizedBox(height: Sp.sm),
            Text('Confirm an order at a store and it will appear here.',
                style: AppText.label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
