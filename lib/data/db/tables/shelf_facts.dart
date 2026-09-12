import 'package:drift/drift.dart';
import 'visits.dart';
import 'skus.dart';

/// Derived table — delete-and-reinsert the whole visit's set on every recompute.
/// Never hand-edit individual rows.
class ShelfFacts extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text().references(Visits, #id)();
  TextColumn get skuId => text().references(Skus, #id)();
  IntColumn get detectedFacings => integer()();
  IntColumn get targetFacings => integer()();
  // in_stock | below_plan | stockout | unlisted
  TextColumn get status => text()();
  IntColumn get computedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {visitId, skuId}
      ];
}
