import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../ml/common/thresholds.dart';
import '../ml/detector/detector_service.dart';
import '../ml/detector/tflite_detector.dart';
import '../ml/embedder/embedder_service.dart';
import '../ml/embedder/sku_index.dart';
import '../ml/embedder/tflite_embedder.dart';
import '../ml/ocr/mlkit_ocr_service.dart';
import '../ml/ocr/ocr_service.dart';

/// Global database provider — single instance for the app lifetime.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Live ML thresholds (Diagnostics sliders, T-25). Loaded from
/// `app_settings` in `main.dart`; every change is written back so it
/// survives a restart. The detector and the recogniser routing read from
/// here, so retuning never needs a rebuild.
final thresholdsProvider = Provider<RuntimeThresholds>((ref) {
  final db = ref.watch(dbProvider);
  return RuntimeThresholds(persist: db.setSetting);
});

/// SKU recogniser (T-20). Created eagerly and loaded in the background at
/// app start (see `main.dart`); until `isLoaded` consumers degrade
/// gracefully (enrolment stores crops only, boxes stay unmatched, the picker
/// shows no ranked candidates). With no `assets/models/embedder_*.tflite`
/// (T-14 pending) load simply fails.
final embedderProvider = Provider<EmbedderService?>((ref) {
  final e = TfliteEmbedder();
  ref.onDispose(e.close);
  return e;
});

/// All active enrolled vectors, in memory. Refreshed at start, after the
/// embedding back-fill, and after every enrolment shot.
final skuIndexProvider = Provider<SkuIndex>((ref) {
  return InMemorySkuIndex(ref.watch(dbProvider));
});

/// Pack detector (T-13). Created eagerly and loaded in the background at
/// app start (see `main.dart`); until `isLoaded` the capture pipeline
/// inserts no boxes and the rep draws them on /review. With no
/// `assets/models/detector_int8.tflite` (T-12 pending) load simply fails
/// and the app stays in manual mode.
final detectorProvider = Provider<DetectorService?>((ref) {
  final d = TfliteDetector();
  // Follow the live thresholds without a rebuild.
  final t = ref.watch(thresholdsProvider);
  void sync() => d.config = DetectorConfig(
        confThreshold: t.detConf,
        nmsIou: t.detNmsIou,
        maxBoxes: t.detMaxBoxes,
      );
  sync();
  t.addListener(sync);
  ref.onDispose(() {
    t.removeListener(sync);
    d.close();
  });
  return d;
});

/// Grammage OCR (F-22 / T-30). ML Kit's Latin recogniser is bundled, so
/// nothing to load up front: the TextRecognizer is created on first use.
/// Only the capture pipeline calls it, and only for a low-confidence match
/// between same-brand size variants.
final ocrProvider = Provider<OcrService?>((ref) {
  final o = MlKitOcrService();
  ref.onDispose(o.close);
  return o;
});
