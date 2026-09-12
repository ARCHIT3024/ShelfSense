/// Stage B — SKU recogniser. Owner: A/C. Task IDs: T-14 (train + export
/// embedder_int8.tflite), T-20 (this service + SkuIndex).
///
/// MobileNetV3-Small, 128-d embedding, L2-normalised at export. Loads all
/// active enrolled vectors once at startup into `SkuIndex`, then does plain
/// brute-force cosine kNN per crop (40 SKUs × 8 embeddings is nowhere near
/// enough vectors to justify FAISS or any ANN index — see docs/Work Flow.md
/// §3). Threshold routing uses kMatchHigh/kMatchLow from
/// lib/ml/common/thresholds.dart.
library;

import '../../core/failures.dart';
import '../../core/result.dart';
import '../../domain/models/models.dart';

abstract class EmbedderService {
  Future<Result<void, Failure>> load();
  Future<Result<List<double>, Failure>> embed(String cropImagePath);
}

/// In-memory nearest-neighbour index over enrolled SKU embeddings.
abstract class SkuIndex {
  Future<void> refresh();
  List<SkuCandidate> topMatches(List<double> queryEmbedding, {int k = 3});
}
