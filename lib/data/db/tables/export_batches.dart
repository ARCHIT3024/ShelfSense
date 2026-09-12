import 'package:drift/drift.dart';
import 'beats.dart';

class ExportBatches extends Table {
  TextColumn get id => text()();
  TextColumn get beatId => text().references(Beats, #id)();
  IntColumn get visitCount => integer()();
  IntColumn get lineCount => integer()();
  IntColumn get totalValuePaise => integer()();
  TextColumn get xlsxPath => text().nullable()();
  TextColumn get csvPath => text().nullable()();
  TextColumn get pdfPath => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
