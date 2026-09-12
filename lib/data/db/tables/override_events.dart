import 'package:drift/drift.dart';

/// Training-signal log. Every rep correction writes a row here.
class OverrideEvents extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text()();
  // detection | order_line
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  // sku_id | final_qty | box | deleted
  TextColumn get field => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
