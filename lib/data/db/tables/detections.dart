import 'package:drift/drift.dart';
import 'visits.dart';
import 'visit_photos.dart';
import 'skus.dart';

class Detections extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text().references(Visits, #id)();
  TextColumn get photoId => text().references(VisitPhotos, #id)();
  // Normalised 0-1 against original photo dimensions — never store pixels
  RealColumn get x1 => real()();
  RealColumn get y1 => real()();
  RealColumn get x2 => real()();
  RealColumn get y2 => real()();
  RealColumn get detConfidence => real()();
  TextColumn get skuId => text().references(Skus, #id).nullable()(); // null = unmatched
  RealColumn get matchConfidence => real().nullable()();
  // embedding | ocr_tiebreak | manual | unmatched
  TextColumn get matchMethod => text().withDefault(const Constant('unmatched'))();
  IntColumn get shelfRow => integer().nullable()(); // assigned by y-clustering
  // Advisory visual gap — not a planogram stockout
  BoolColumn get isGap => boolean().withDefault(const Constant(false))();
  BoolColumn get wasCorrected => boolean().withDefault(const Constant(false))();
  // Kept only for corrected boxes — free future training data
  BlobColumn get embedding => blob().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
