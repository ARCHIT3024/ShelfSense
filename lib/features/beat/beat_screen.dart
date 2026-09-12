import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart';
import '../../data/seed/seed_data.dart';

class BeatScreen extends ConsumerStatefulWidget {
  const BeatScreen({super.key});

  @override
  ConsumerState<BeatScreen> createState() => _BeatScreenState();
}

class _BeatScreenState extends ConsumerState<BeatScreen> {
  // Live: re-queries whenever any table changes (a confirmed order, a new
  // draft, a seed) so the pills and header never go stale, regardless of
  // which route brought the rep back here.
  late final Stream<_BeatData> _stream = _watchBeatData(ref.read(dbProvider));

  Stream<_BeatData> _watchBeatData(AppDatabase db) async* {
    yield await _loadBeatData(db);
    await for (final _ in db.tableUpdates()) {
      yield await _loadBeatData(db);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(dbProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShelfSense'),
        actions: [
          // OFFLINE badge — always visible, styled as a feature
          Container(
            margin: const EdgeInsets.only(right: Sp.lg),
            padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.xs),
            decoration: BoxDecoration(
              color: AppColors.offlineBg,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.offlineFg, shape: BoxShape.circle),
                ),
                const SizedBox(width: Sp.xs),
                const Text('OFFLINE',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.offlineFg, letterSpacing: 0.8)),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final beat = data.beat;
          final stores = data.stores;

          if (stores.isEmpty) {
            return _EmptyState(onLoadDemo: () => runSeed(db));
          }

          return Column(
            children: [
              // Summary strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: Sp.screen, vertical: Sp.md),
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            beat?.name ?? "Today's Beat",
                            style: AppText.heading,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM').format(DateTime.now()),
                          style: AppText.label,
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.xs),
                    Text(
                      '${data.doneCount} / ${stores.length} done'
                      '  ·  ₹${NumberFormat('#,##0').format(data.valuePaise ~/ 100)}'
                      '  ·  ${data.stockouts} stockout${data.stockouts == 1 ? '' : 's'}',
                      style: AppText.mono.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Store list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Sp.screen, vertical: Sp.md),
                  itemCount: stores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Sp.sm),
                  itemBuilder: (context, i) {
                    final s = stores[i];
                    final status = data.statusOf(s);
                    return _StoreRow(
                      store: s,
                      status: status,
                      // A draft resumes where the rep left off.
                      onTap: () => context.push(status == 'draft'
                          ? '/review/${data.latestVisit[s.id]!.id}'
                          : '/store/${s.id}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/export'),
        icon: const Icon(Icons.file_download_outlined),
        label: const Text('Export Beat'),
      ),
    );
  }

  Future<_BeatData> _loadBeatData(AppDatabase db) async {
    final beats = await db.select(db.beats).get();
    final stores = await (db.select(db.stores)
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();

    // Latest visit per store decides the pill; confirmed visits feed the
    // header numbers (06_APP_FLOW §`/beat`).
    final visits = await (db.select(db.visits)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    // A draft with no photo yet is just "Start Visit" then back — it must
    // not demote a Done store to Resume. Only drafts with a photo count.
    final photoVisitIds =
        (await db.select(db.visitPhotos).get()).map((p) => p.visitId).toSet();
    final latest = <String, Visit>{};
    for (final v in visits) {
      if (v.status == 'draft' && !photoVisitIds.contains(v.id)) continue;
      latest.putIfAbsent(v.storeId, () => v);
    }
    final confirmedIds = [
      for (final v in latest.values)
        if (v.status != 'draft') v.id,
    ];

    var valuePaise = 0;
    var stockouts = 0;
    if (confirmedIds.isNotEmpty) {
      final lines = await (db.select(db.orderLines)
            ..where((t) => t.visitId.isIn(confirmedIds)))
          .get();
      valuePaise = lines.fold(0, (sum, l) => sum + l.valuePaise);
      final facts = await (db.select(db.shelfFacts)
            ..where((t) =>
                t.visitId.isIn(confirmedIds) & t.status.equals('stockout')))
          .get();
      stockouts = facts.length;
    }

    return _BeatData(
      beat: beats.isEmpty ? null : beats.first,
      stores: stores,
      latestVisit: latest,
      doneCount: confirmedIds.length,
      valuePaise: valuePaise,
      stockouts: stockouts,
    );
  }
}

class _BeatData {
  const _BeatData({
    required this.beat,
    required this.stores,
    required this.latestVisit,
    required this.doneCount,
    required this.valuePaise,
    required this.stockouts,
  });
  final Beat? beat;
  final List<Store> stores;
  final Map<String, Visit> latestVisit;
  final int doneCount, valuePaise, stockouts;

  String statusOf(Store s) {
    final v = latestVisit[s.id];
    if (v == null) return 'pending';
    return v.status == 'draft' ? 'draft' : 'done';
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow(
      {required this.store, required this.status, required this.onTap});
  final Store store;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(Radii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Sp.lg, vertical: Sp.md),
          child: Row(
            children: [
              // Sequence circle
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  store.sequence.toString(),
                  style: AppText.mono.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: AppText.heading),
                    const SizedBox(height: 2),
                    Text(store.code, style: AppText.label),
                  ],
                ),
              ),
              // Status pill — pending for now
              _StatusPill(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'done' => (AppColors.success, 'Done'),
      'draft' => (AppColors.warning, 'Resume'),
      _ => (AppColors.textDisabled, 'Pending'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Sp.md, vertical: Sp.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onLoadDemo});
  final VoidCallback onLoadDemo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined,
                size: 64, color: AppColors.textDisabled),
            const SizedBox(height: Sp.lg),
            const Text('No stores in this beat',
                style: AppText.heading, textAlign: TextAlign.center),
            const SizedBox(height: Sp.xxl),
            FilledButton(
              onPressed: onLoadDemo,
              child: const Text('Load Demo Beat'),
            ),
          ],
        ),
      ),
    );
  }
}
