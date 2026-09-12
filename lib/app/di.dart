import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../ml/detector/detector_service.dart';
import '../ml/detector/tflite_detector.dart';
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

/// Pack detector (T-13). Created eagerly and loaded in the background at
/// app start (see `main.dart`); until `isLoaded` the capture pipeline
/// inserts no boxes and the rep draws them on /review. With no
/// `assets/models/detector_int8.tflite` (T-12 pending) load simply fails
/// and the app stays in manual mode.
final detectorProvider = Provider<DetectorService?>((ref) {
  final d = TfliteDetector();
  ref.onDispose(d.close);
  return d;
});
