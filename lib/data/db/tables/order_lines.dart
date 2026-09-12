import 'package:drift/drift.dart';
import 'visits.dart';
import 'skus.dart';

class OrderLines extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text().references(Visits, #id)();
  TextColumn get skuId => text().references(Skus, #id)();
  // Never mutated after creation — immutable model draft enables override-rate metric
  IntColumn get suggestedQty => integer()();
  IntColumn get finalQty => integer()();
  // case | piece
  TextColumn get unit => text().withDefault(const Constant('piece'))();
  // finalQty × mrpPaise × (caseSize if unit=case)
  IntColumn get valuePaise => integer()();
  BoolColumn get wasOverridden => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {visitId, skuId}
      ];
}
