import 'package:drift/drift.dart';
import 'stores.dart';
import 'beats.dart';

class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get beatId => text().references(Beats, #id)(); // denormalised — export groups by beat
  // draft | confirmed | exported
  TextColumn get status => text().withDefault(const Constant('draft'))();
  IntColumn get startedAt => integer()();
  IntColumn get confirmedAt => integer().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get gpsAccuracyM => real().nullable()();
  // Capture the real connectivity state — evidence for the pitch, never hardcoded
  BoolColumn get wasOffline => boolean().withDefault(const Constant(true))();
  TextColumn get noteAudioPath => text().nullable()();
  TextColumn get noteTranscript => text().nullable()();
  TextColumn get llmSummary => text().nullable()(); // free text only
  TextColumn get llmRationale => text().nullable()(); // free text only
  TextColumn get llmModelId => text().nullable()(); // null ⇒ deterministic fallback used
  IntColumn get durationMs => integer().nullable()(); // Productivity KPI

  @override
  Set<Column> get primaryKey => {id};
}
