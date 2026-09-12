import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../core/ids.dart';
import '../../data/db/database.dart';

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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final store = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(store.name)),
          body: ListView(
            padding: const EdgeInsets.all(Sp.screen),
            children: [
              // Info card
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
                    if (store.phone != null)
                      _InfoRow('Phone', store.phone!),
                    if (store.address != null)
                      _InfoRow('Address', store.address!),
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
                child: const Text('Start Visit'),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Store> _load(AppDatabase db) async {
    final row = await (db.select(db.stores)
          ..where((t) => t.id.equals(storeId)))
        .getSingle();
    return row;
  }

  Future<void> _startVisit(
      BuildContext context, AppDatabase db, Store store) async {
    final visitId = newId();
    final now = DateTime.now().millisecondsSinceEpoch;
    // Get beat for this store
    await db.into(db.visits).insert(VisitsCompanion.insert(
          id: visitId,
          storeId: store.id,
          beatId: store.beatId,
          startedAt: now,
        ));
    if (context.mounted) context.push('/capture/$visitId');
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
