import 'package:drift/drift.dart';

class Beats extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // e.g. BEAT-12
  TextColumn get name => text()();
  TextColumn get repName => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
