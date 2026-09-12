import 'package:drift/drift.dart';

/// Key/value store for runtime-tunable settings.
/// Seeded keys: all thresholds from TRD §4.1, plus llm_enabled, ocr_enabled,
/// demo_mode, active_beat_id.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
