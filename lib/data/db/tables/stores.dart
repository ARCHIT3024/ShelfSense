import 'package:drift/drift.dart';
import 'beats.dart';

class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // e.g. KIR-0412
  TextColumn get name => text()();
  TextColumn get beatId => text().references(Beats, #id)();
  TextColumn get address => text().nullable()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get phone => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  IntColumn get sequence => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
