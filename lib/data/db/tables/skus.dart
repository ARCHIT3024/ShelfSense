import 'package:drift/drift.dart';

class Skus extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // e.g. NDL-70
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get grammageValue => real().nullable()();
  // g | kg | ml | l | n
  TextColumn get grammageUnit => text().nullable()();
  TextColumn get variant => text().nullable()();
  IntColumn get mrpPaise => integer().withDefault(const Constant(0))();
  IntColumn get caseSize => integer().withDefault(const Constant(1))();
  // 1 once ≥ kMinEnrolShots active embeddings exist
  BoolColumn get isEnrolled => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
