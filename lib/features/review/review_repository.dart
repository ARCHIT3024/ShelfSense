import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../core/logger.dart';
import '../../data/db/database.dart';
import '../../ml/common/thresholds.dart';

const _tag = 'ReviewRepo';

/// Visual state of a box on `/review` — drives colour, chip and tap action
/// (06_APP_FLOW.md §`/review`).
enum BoxState { matchedHigh, matchedLow, unmatched, gap }

/// [acceptThreshold] defaults to the compiled constant; pass the live
/// Diagnostics value so /review agrees with what the pipeline accepted.
BoxState boxStateOf(Detection d, {double acceptThreshold = kMatchHigh}) {
  if (d.isGap) return BoxState.gap;
  if (d.skuId == null) return BoxState.unmatched;
  // Manual tags and OCR-settled size variants are accepted regardless of the
  // embedding score that preceded them.
  if (d.matchMethod == 'manual' ||
      d.matchMethod == 'ocr_tiebreak' ||
      (d.matchConfidence ?? 0) >= acceptThreshold) {
    return BoxState.matchedHigh;
  }
  return BoxState.matchedLow;
}

class ReviewData {
  const ReviewData({
    required this.photos,
    required this.detections,
    required this.skus,
  });
  final List<VisitPhoto> photos;
  final List<Detection> detections;
  final List<SkusData> skus;

  SkusData? skuById(String? id) {
    if (id == null) return null;
    for (final s in skus) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// All reads and writes behind `/review`. Every rep correction goes through
/// here so that `override_events` is written alongside the change.
class ReviewRepository {
  ReviewRepository(this.db);
  final AppDatabase db;

  Future<ReviewData> load(String visitId) async {
    final photos = await (db.select(db.visitPhotos)
          ..where((t) => t.visitId.equals(visitId))
          ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
        .get();
    final detections = await (db.select(db.detections)
          ..where((t) => t.visitId.equals(visitId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    final skus = await (db.select(db.skus)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return ReviewData(photos: photos, detections: detections, skus: skus);
  }

  Future<void> _logOverride({
    required String visitId,
    required String detectionId,
    required String field,
    String? oldValue,
    String? newValue,
  }) {
    return db.into(db.overrideEvents).insert(OverrideEventsCompanion.insert(
          id: newId(),
          visitId: visitId,
          entity: 'detection',
          entityId: detectionId,
          field: field,
          oldValue: Value(oldValue),
          newValue: Value(newValue),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
  }

  /// Rep picked a SKU for a box (correction or first tag).
  Future<void> setSku(Detection d, SkusData sku) async {
    await (db.update(db.detections)..where((t) => t.id.equals(d.id))).write(
      DetectionsCompanion(
        skuId: Value(sku.id),
        matchConfidence: const Value(1.0),
        matchMethod: const Value('manual'),
        wasCorrected: const Value(true),
        isGap: const Value(false),
      ),
    );
    await _logOverride(
      visitId: d.visitId,
      detectionId: d.id,
      field: 'sku_id',
      oldValue: d.skuId,
      newValue: sku.id,
    );
    AppLogger.i(_tag, 'Box ${d.id} tagged as ${sku.code}');
  }

  Future<void> deleteBox(Detection d) async {
    await (db.delete(db.detections)..where((t) => t.id.equals(d.id))).go();
    await _logOverride(
      visitId: d.visitId,
      detectionId: d.id,
      field: 'deleted',
      oldValue: _coords(d.x1, d.y1, d.x2, d.y2),
    );
  }

  /// Gap boxes are advisory; dismissing one is not a correction, so no
  /// override event is written.
  Future<void> dismissGap(Detection d) {
    return (db.delete(db.detections)..where((t) => t.id.equals(d.id))).go();
  }

  Future<void> updateBox(
      Detection d, double x1, double y1, double x2, double y2) async {
    await (db.update(db.detections)..where((t) => t.id.equals(d.id))).write(
      DetectionsCompanion(
        x1: Value(x1),
        y1: Value(y1),
        x2: Value(x2),
        y2: Value(y2),
        wasCorrected: const Value(true),
      ),
    );
    await _logOverride(
      visitId: d.visitId,
      detectionId: d.id,
      field: 'box',
      oldValue: _coords(d.x1, d.y1, d.x2, d.y2),
      newValue: _coords(x1, y1, x2, y2),
    );
  }

  /// Rep drew a box the detector missed. Starts life unmatched; the picker
  /// opens immediately afterwards.
  Future<Detection> insertManualBox({
    required String visitId,
    required String photoId,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) async {
    final id = newId();
    final now = DateTime.now().millisecondsSinceEpoch;
    final companion = DetectionsCompanion.insert(
      id: id,
      visitId: visitId,
      photoId: photoId,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      detConfidence: 1.0,
      wasCorrected: const Value(true),
      createdAt: now,
    );
    await db.into(db.detections).insert(companion);
    await _logOverride(
      visitId: visitId,
      detectionId: id,
      field: 'box',
      newValue: _coords(x1, y1, x2, y2),
    );
    return (db.select(db.detections)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  static String _coords(double x1, double y1, double x2, double y2) =>
      '${x1.toStringAsFixed(4)},${y1.toStringAsFixed(4)},'
      '${x2.toStringAsFixed(4)},${y2.toStringAsFixed(4)}';
}
