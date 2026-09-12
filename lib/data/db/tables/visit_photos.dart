import 'package:drift/drift.dart';
import 'visits.dart';

class VisitPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text().references(Visits, #id)();
  TextColumn get filePath => text()(); // app-private storage
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  IntColumn get detectLatencyMs => integer().nullable()(); // per-photo; feeds benchmark slide
  IntColumn get capturedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
