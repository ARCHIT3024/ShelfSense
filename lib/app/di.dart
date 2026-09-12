import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../ml/detector/detector_service.dart';
import '../ml/embedder/embedder_service.dart';

/// Global database provider — single instance for the app lifetime.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// SKU recogniser (T-20). `null` until the embedder model + service land —
/// consumers must degrade gracefully (enrolment stores crops only, the
/// picker shows no ranked candidates).
final embedderProvider = Provider<EmbedderService?>((ref) => null);

/// Pack detector (T-13). `null` until the YOLO .tflite + service land; the
/// capture pipeline then inserts no boxes and the rep draws them on /review.
final detectorProvider = Provider<DetectorService?>((ref) => null);
