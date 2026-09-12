/// Stage C — grammage/variant disambiguator. Owner: whoever picks up L3.
/// Task: T-30, strictly time-boxed (04:00–05:00 Sunday per docs/Work Flow.md
/// §6). Anything not working by 05:00 gets reverted, not fixed.
///
/// Wraps google_mlkit_text_recognition (fully offline, bundled). Runs only
/// on low-confidence crops (below kMatchHigh, above kMatchLow — see
/// lib/ml/common/thresholds.dart) to split near-identical packs, e.g. 500 g
/// vs 1 kg of the same brand. Latin script first; Devanagari/Tamil only if
/// time remains.
library;

import '../../core/failures.dart';
import '../../core/result.dart';

abstract class OcrService {
  Future<Result<String, Failure>> recognizeText(String cropImagePath);
}
