import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import '../../core/ids.dart';
import '../../core/logger.dart';
import '../db/database.dart';

const _tag = 'SeedData';

/// Run once on first launch (schema onCreate).
/// Call from the boot screen if the beats table is empty.
Future<void> runSeed(AppDatabase db) async {
  try {
    final beatCount = await db.select(db.beats).get();
    if (beatCount.isNotEmpty) {
      // Already seeded: still top up planogram rows added to the seed file
      // later (unique on store+sku, insertOrIgnore, so this is idempotent).
      await _seedPlanogram(db);
      AppLogger.i(_tag, 'Seed already applied — planogram topped up');
      return;
    }
    AppLogger.i(_tag, 'Running initial seed…');
    await _seedBeats(db);
    await _seedStores(db);
    await _seedSkus(db);
    await _seedPlanogram(db);
    AppLogger.i(_tag, 'Seed complete');
  } catch (e) {
    AppLogger.e(_tag, 'Seed failed', e);
  }
}

Future<void> _seedBeats(AppDatabase db) async {
  final raw = await rootBundle.loadString('assets/seed/seed_beats.json');
  final list = jsonDecode(raw) as List;
  await db.batch((b) {
    for (final m in list) {
      b.insert(db.beats, BeatsCompanion.insert(
        id: m['id'] as String,
        code: m['code'] as String,
        name: m['name'] as String,
        repName: Value(m['rep_name'] as String?),
        createdAt: (m['created_at'] as int?) ??
            DateTime.now().millisecondsSinceEpoch,
      ), mode: InsertMode.insertOrIgnore);
    }
  });
}

Future<void> _seedStores(AppDatabase db) async {
  final raw = await rootBundle.loadString('assets/seed/seed_stores.json');
  final list = jsonDecode(raw) as List;
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.batch((b) {
    for (final m in list) {
      b.insert(db.stores, StoresCompanion.insert(
        id: m['id'] as String,
        code: m['code'] as String,
        name: m['name'] as String,
        beatId: m['beat_id'] as String,
        address: Value(m['address'] as String?),
        ownerName: Value(m['owner_name'] as String?),
        phone: Value(m['phone'] as String?),
        sequence: Value(m['sequence'] as int? ?? 0),
        createdAt: now,
      ), mode: InsertMode.insertOrIgnore);
    }
  });
}

Future<void> _seedSkus(AppDatabase db) async {
  final raw = await rootBundle.loadString('assets/seed/seed_skus.json');
  final list = jsonDecode(raw) as List;
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.batch((b) {
    for (final m in list) {
      b.insert(db.skus, SkusCompanion.insert(
        id: m['id'] as String,
        code: m['code'] as String,
        name: m['name'] as String,
        brand: Value(m['brand'] as String?),
        category: Value(m['category'] as String?),
        grammageValue: Value((m['grammage_value'] as num?)?.toDouble()),
        grammageUnit: Value(m['grammage_unit'] as String?),
        variant: Value(m['variant'] as String?),
        mrpPaise: Value(m['mrp_paise'] as int? ?? 0),
        caseSize: Value(m['case_size'] as int? ?? 1),
        createdAt: now,
      ), mode: InsertMode.insertOrIgnore);
    }
  });
}

Future<void> _seedPlanogram(AppDatabase db) async {
  final raw = await rootBundle.loadString('assets/seed/seed_planogram.json');
  final list = jsonDecode(raw) as List;
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.batch((b) {
    for (final m in list) {
      b.insert(db.planogramEntries, PlanogramEntriesCompanion.insert(
        id: newId(),
        storeId: m['store_id'] as String,
        skuId: m['sku_id'] as String,
        targetFacings: m['target_facings'] as int,
        shelfRow: Value(m['shelf_row'] as int?),
        source: (m['source'] as String?) ?? 'manual',
        updatedAt: now,
      ), mode: InsertMode.insertOrIgnore);
    }
  });
}
