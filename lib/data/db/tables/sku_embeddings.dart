import 'package:drift/drift.dart';
import 'skus.dart';

class SkuEmbeddings extends Table {
  TextColumn get id => text()();
  TextColumn get skuId => text().references(Skus, #id)();
  // 128 × float32 little-endian = 512 bytes exactly
  BlobColumn get vector => blob()();
  TextColumn get sourceImagePath => text().nullable()();
  // bright | dim | angled | occluded
  TextColumn get captureContext => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
