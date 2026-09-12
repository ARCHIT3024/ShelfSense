/// Stage A — class-agnostic pack finder. Owner: A. Task IDs: T-12 (export
/// detector_int8.tflite), T-13 (this service).
///
/// Loads the YOLO11n INT8 TFLite model, letterbox-preprocesses a captured
/// still image in an isolate, runs inference via tflite_flutter with the GPU
/// delegate (XNNPACK fallback), decodes YOLO output, and applies
/// class-agnostic NMS. See docs/02_TRD.md for the tensor contract — assert
/// input/output shapes before writing decode logic, per T-13's own warning
/// in docs/03_IMPLEMENTATION_PLAN.md.
///
/// Must not run on the camera preview stream — detect on shutter press only
/// (see docs/00_START_HERE.md, non-negotiable #4).
library;

import '../../core/failures.dart';
import '../../core/result.dart';
import '../../domain/models/models.dart';

abstract class DetectorService {
  Future<Result<void, Failure>> load();
  Future<Result<List<RawBox>, Failure>> detect(String imagePath);
}
