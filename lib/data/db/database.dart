import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings.dart';
import 'tables/beats.dart';
import 'tables/detections.dart';
import 'tables/export_batches.dart';
import 'tables/model_registry.dart';
import 'tables/order_lines.dart';
import 'tables/override_events.dart';
import 'tables/planogram_entries.dart';
import 'tables/shelf_facts.dart';
import 'tables/sku_embeddings.dart';
import 'tables/skus.dart';
import 'tables/stores.dart';
import 'tables/visit_photos.dart';
import 'tables/visits.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Beats,
  Stores,
  Skus,
  SkuEmbeddings,
  PlanogramEntries,
  Visits,
  VisitPhotos,
  Detections,
  ShelfFacts,
  OrderLines,
  OverrideEvents,
  ExportBatches,
  ModelRegistry,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedSettings();
        },
      );

  // ---- settings helpers ------------------------------------------------

  Future<void> _seedSettings() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final defaults = {
      'det_conf_threshold': '0.35',
      'det_nms_iou': '0.50',
      'det_max_boxes': '100',
      'match_high': '0.72',
      'match_low': '0.55',
      'min_enrol_shots': '3',
      'target_enrol_shots': '8',
      'gap_min_area': '0.004',
      'llm_enabled': '1',
      'ocr_enabled': '0',
      'demo_mode': '0',
      'active_beat_id': '',
    };
    await batch((b) {
      for (final e in defaults.entries) {
        b.insert(
          appSettings,
          AppSettingsCompanion.insert(
            key: e.key,
            value: e.value,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // ---- demo-mode reset -------------------------------------------------

  /// Wipes visits, photos, detections, shelf_facts, order_lines, override_events,
  /// and export_batches WITHOUT touching skus or sku_embeddings.
  /// Call from the Diagnostics screen between demo runs.
  Future<void> resetForDemo() => transaction(() async {
        await delete(overrideEvents).go();
        await delete(orderLines).go();
        await delete(shelfFacts).go();
        await delete(detections).go();
        await delete(visitPhotos).go();
        await delete(exportBatches).go();
        await delete(visits).go();
        await setSetting('demo_mode', '1');
      });
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'shelfsense',
    native: DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}
