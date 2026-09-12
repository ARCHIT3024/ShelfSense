import 'package:drift/drift.dart';
import 'stores.dart';
import 'skus.dart';

class PlanogramEntries extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get skuId => text().references(Skus, #id)();
  IntColumn get targetFacings => integer()();
  IntColumn get shelfRow => integer().nullable()(); // 1 = top
  // manual | history | default
  TextColumn get source => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {storeId, skuId}
      ];
}
