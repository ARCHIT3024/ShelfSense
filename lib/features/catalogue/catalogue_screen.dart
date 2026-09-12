import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart';
import '../../ml/common/thresholds.dart';

/// Enrolment state of one SKU, derived from its active embedding count.
enum EnrolState { enrolled, partial, none }

/// Pure so it can be unit-tested: `kMinEnrolShots` active vectors ⇒ enrolled,
/// anything above zero but below that ⇒ partial.
EnrolState enrolStateFor(int activeEmbeddings) {
  if (activeEmbeddings >= kMinEnrolShots) return EnrolState.enrolled;
  if (activeEmbeddings > 0) return EnrolState.partial;
  return EnrolState.none;
}

class _CatalogueRow {
  const _CatalogueRow(this.sku, this.shots);
  final SkusData sku;
  final int shots;
  EnrolState get state => enrolStateFor(shots);
}

/// Active SKUs joined with their active embedding counts (one grouped query).
/// Live: re-queries on any table change so a fresh enrolment shows at once.
final _catalogueProvider =
    StreamProvider.autoDispose<List<_CatalogueRow>>((ref) async* {
  final db = ref.watch(dbProvider);
  Future<List<_CatalogueRow>> load() async {
    final skus = await (db.select(db.skus)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.name)]))
        .get();
    final count = db.skuEmbeddings.id.count();
    final grouped = await (db.selectOnly(db.skuEmbeddings)
          ..addColumns([db.skuEmbeddings.skuId, count])
          ..where(db.skuEmbeddings.isActive.equals(true))
          ..groupBy([db.skuEmbeddings.skuId]))
        .get();
    final shots = {
      for (final r in grouped)
        r.read(db.skuEmbeddings.skuId)!: r.read(count) ?? 0,
    };
    return [for (final s in skus) _CatalogueRow(s, shots[s.id] ?? 0)];
  }

  yield await load();
  await for (final _ in db.tableUpdates()) {
    yield await load();
  }
});

/// `/catalogue` — SKU list with enrolment status (06_APP_FLOW nav graph).
class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  String _query = '';

  /// Retires a mistaken or duplicate SKU: it leaves the catalogue, the
  /// picker and the recogniser index; nothing is deleted, so history stays
  /// intact. Long-press a row to reach this.
  Future<void> _confirmDeactivate(SkusData sku) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${sku.name}?'),
        content: const Text(
            'It will no longer be listed or recognised. Past visits keep it.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final db = ref.read(dbProvider);
    await (db.update(db.skus)..where((t) => t.id.equals(sku.id)))
        .write(const SkusCompanion(isActive: drift.Value(false)));
    await (db.update(db.skuEmbeddings)..where((t) => t.skuId.equals(sku.id)))
        .write(const SkuEmbeddingsCompanion(isActive: drift.Value(false)));
    await ref.read(skuIndexProvider).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_catalogueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue')),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Sp.xxl),
            child: Text('Could not load the catalogue.\n$e',
                style: AppText.body, textAlign: TextAlign.center),
          ),
        ),
        data: (rows) => _buildList(rows),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/enrol'),
        icon: const Icon(Icons.add),
        label: const Text('New SKU'),
      ),
    );
  }

  Widget _buildList(List<_CatalogueRow> rows) {
    final enrolled =
        rows.where((r) => r.state == EnrolState.enrolled).length;
    final q = _query.toLowerCase();
    final visible = q.isEmpty
        ? rows
        : rows.where((r) {
            final s = r.sku;
            return s.name.toLowerCase().contains(q) ||
                s.code.toLowerCase().contains(q) ||
                (s.brand?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.md, Sp.screen, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$enrolled of ${rows.length} SKUs enrolled',
              style: AppText.mono.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.sm, Sp.screen, Sp.sm),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: const InputDecoration(
              hintText: 'Search name, code or brand',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(
                    q.isEmpty ? 'No SKUs yet' : 'No SKU matches "$_query"',
                    style: AppText.body.copyWith(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  // Leave room for the FAB over the last row.
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: visible.length,
                  itemBuilder: (_, i) => _SkuTile(
                    row: visible[i],
                    onTap: () => context
                        .push('/enrol', extra: {'skuId': visible[i].sku.id}),
                    onLongPress: () => _confirmDeactivate(visible[i].sku),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SkuTile extends StatelessWidget {
  const _SkuTile(
      {required this.row, required this.onTap, required this.onLongPress});
  final _CatalogueRow row;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final s = row.sku;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      minTileHeight: Tap.counter,
      title: Text(s.name, style: AppText.body),
      subtitle: Text(
        [s.code, if (s.brand != null) s.brand!].join(' · '),
        style: AppText.label,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_grammage(s), style: AppText.mono),
          const SizedBox(width: Sp.md),
          _EnrolPill(state: row.state, shots: row.shots),
        ],
      ),
    );
  }
}

class _EnrolPill extends StatelessWidget {
  const _EnrolPill({required this.state, required this.shots});
  final EnrolState state;
  final int shots;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state) {
      EnrolState.enrolled => (AppColors.success, 'Enrolled · $shots'),
      EnrolState.partial => (AppColors.warning, 'Partial · $shots'),
      EnrolState.none => (AppColors.textDisabled, 'Not enrolled'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppText.label
            .copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}

String _grammage(SkusData s) {
  final v = s.grammageValue;
  if (v == null) return '';
  final disp = v == v.floorToDouble() ? v.toInt().toString() : v.toString();
  return '$disp ${s.grammageUnit ?? ''}'.trim();
}
