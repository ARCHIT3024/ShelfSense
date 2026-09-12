import 'package:drift/drift.dart';

/// Records per-model load status and latency. Drives the Diagnostics screen
/// and supplies the real numbers that replace `000 ms` on the pitch slide.
class ModelRegistry extends Table {
  TextColumn get id => text()();
  // detector | embedder | llm | asr | ocr
  TextColumn get kind => text()();
  TextColumn get label => text()(); // e.g. yolo11n-sku110k-int8
  TextColumn get assetPath => text()();
  BoolColumn get loadedOk => boolean().withDefault(const Constant(false))();
  IntColumn get loadMs => integer().nullable()();
  RealColumn get meanLatencyMs => real().nullable()();
  IntColumn get runCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
