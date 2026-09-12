import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../core/ids.dart';
import '../../data/db/database.dart';

/// `/store` — the pre-visit brief (04_UIUX §`/store`): details, three stat
/// tiles from the last confirmed visit, the planogram's top SKUs, Start visit.
class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key, required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: _load(db),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary)));
        }
        final brief = snap.data!;
        final store = brief.store;
        final money = NumberFormat('#,##0');
        return Scaffold(
          appBar: AppBar(title: Text(store.name)),
          body: ListView(
            padding: const EdgeInsets.all(Sp.screen),
            children: [
              // Details card
              Container(
                padding: const EdgeInsets.all(Sp.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('Code', store.code),
                    if (store.ownerName != null)
                      _InfoRow('Owner', store.ownerName!),
                    if (store.phone != null) _InfoRow('Phone', store.phone!),
                    if (store.address != null)
                      _InfoRow('Address', store.address!),
                  ],
                ),
              ),
              const SizedBox(height: Sp.md),
              // Stat tiles — last confirmed visit at this store
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Last visit',
                      value: brief.lastVisitAt == null
                          ? 'First visit'
                          : DateFormat('d MMM · HH:mm').format(brief.lastVisitAt!),
                      small: brief.lastVisitAt == null,
                    ),
                  ),
                  const SizedBox(width: Sp.sm),
                  Expanded(
                    child: _StatTile(
                      label: 'Last order',
                      value: brief.lastVisitAt == null
                          ? '–'
                          : '₹${money.format(brief.lastOrderPaise ~/ 100)}',
                    ),
                  ),
                  const SizedBox(width: Sp.sm),
                  Expanded(
                    child: _StatTile(
                      label: 'Stockouts',
                      value: brief.lastVisitAt == null
                          ? '–'
                          : '${brief.lastStockouts}',
                      valueColor: brief.lastStockouts > 0
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.lg),
              // Planogram preview
              Text('Planogram', style: AppText.heading),
              const SizedBox(height: Sp.xs),
              Text(
                brief.planogram.isEmpty
                    ? 'No planogram for this store yet.'
                    : 'Top ${brief.planogram.length} of ${brief.planogramCount} SKUs by target facings',
                style: AppText.label,
              ),
              const SizedBox(height: Sp.sm),
              if (brief.planogram.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Radii.card),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < brief.planogram.length; i++)
                        _PlanRow(
                          entry: brief.planogram[i],
                          last: i == brief.planogram.length - 1,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: Sp.xxl),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Sp.screen, Sp.sm, Sp.screen, Sp.lg),
              child: FilledButton(
                onPressed: () => _startVisit(context, db, store),
                child: const Text('Start visit'),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_Brief> _load(AppDatabase db) async {
    final store = await (db.select(db.stores)
          ..where((t) => t.id.equals(storeId)))
        .getSingle();

    // Latest confirmed visit → its order value and stockout count.
    final last = await (db.select(db.visits)
          ..where((t) =>
              t.storeId.equals(storeId) & t.status.isNotValue('draft'))
          ..orderBy([(t) => OrderingTerm.desc(t.confirmedAt)])
          ..limit(1))
        .getSingleOrNull();
    var lastOrderPaise = 0;
    var lastStockouts = 0;
    if (last != null) {
      final lines = await (db.select(db.orderLines)
            ..where((t) => t.visitId.equals(last.id)))
          .get();
      lastOrderPaise = lines.fold(0, (s, l) => s + l.valuePaise);
      lastStockouts = (await (db.select(db.shelfFacts)
                ..where((t) =>
                    t.visitId.equals(last.id) & t.status.equals('stockout')))
              .get())
          .length;
    }

    // Planogram: top 5 by target facings, joined with SKU names.
    final plan = await (db.select(db.planogramEntries)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.targetFacings)]))
        .get();
    final skuIds = plan.map((p) => p.skuId).toSet().toList();
    final skus = skuIds.isEmpty
        ? <SkusData>[]
        : await (db.select(db.skus)..where((t) => t.id.isIn(skuIds))).get();
    final byId = {for (final s in skus) s.id: s};
    final top = [
      for (final p in plan.take(5))
        _PlanEntry(
          name: byId[p.skuId]?.name ?? p.skuId,
          grammage: _grammage(byId[p.skuId]),
          targetFacings: p.targetFacings,
          shelfRow: p.shelfRow,
        ),
    ];

    return _Brief(
      store: store,
      lastVisitAt: last == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              last.confirmedAt ?? last.startedAt),
      lastOrderPaise: lastOrderPaise,
      lastStockouts: lastStockouts,
      planogram: top,
      planogramCount: plan.length,
    );
  }

  static String _grammage(SkusData? s) {
    final v = s?.grammageValue;
    if (s == null || v == null) return '';
    final disp = v == v.floorToDouble() ? v.toInt().toString() : v.toString();
    return '$disp ${s.grammageUnit ?? ''}'.trim();
  }

  Future<void> _startVisit(
      BuildContext context, AppDatabase db, Store store) async {
    final visitId = newId();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.visits).insert(VisitsCompanion.insert(
          id: visitId,
          storeId: store.id,
          beatId: store.beatId,
          startedAt: now,
        ));
    if (context.mounted) context.push('/capture/$visitId');
  }
}

class _Brief {
  const _Brief({
    required this.store,
    required this.lastVisitAt,
    required this.lastOrderPaise,
    required this.lastStockouts,
    required this.planogram,
    required this.planogramCount,
  });
  final Store store;
  final DateTime? lastVisitAt;
  final int lastOrderPaise, lastStockouts, planogramCount;
  final List<_PlanEntry> planogram;
}

class _PlanEntry {
  const _PlanEntry({
    required this.name,
    required this.grammage,
    required this.targetFacings,
    this.shelfRow,
  });
  final String name, grammage;
  final int targetFacings;
  final int? shelfRow;
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.valueColor,
    this.small = false,
  });
  final String label, value;
  final Color? valueColor;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppText.label.copyWith(fontSize: 10, letterSpacing: 0.8)),
          const SizedBox(height: Sp.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.mono.copyWith(
              fontSize: small ? 14 : 18,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.entry, required this.last});
  final _PlanEntry entry;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: AppText.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  [
                    if (entry.grammage.isNotEmpty) entry.grammage,
                    if (entry.shelfRow != null) 'row ${entry.shelfRow}',
                  ].join(' · '),
                  style: AppText.label,
                ),
              ],
            ),
          ),
          Text('${entry.targetFacings}',
              style: AppText.mono
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: Sp.xs),
          Text('facings', style: AppText.label),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppText.label),
          ),
          Expanded(child: Text(value, style: AppText.body)),
        ],
      ),
    );
  }
}
