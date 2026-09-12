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
import '../common/image_crop.dart';

abstract class EmbedderService {
  /// True once [load] succeeded; callers skip recognition (boxes stay
  /// unmatched) rather than wait when this is false.
  bool get isLoaded;

  /// Identifies the loaded weights (asset name + byte length). Vectors from
  /// a different model live in a different space, so stored embeddings must
  /// be rebuilt whenever this changes.
  String? get fingerprint;
  Future<Result<void, Failure>> load();
  Future<Result<List<double>, Failure>> embed(String cropImagePath);

  /// Embeds several boxes of one still. The default decodes the still once
  /// per box; implementations override to decode once for all.
  Future<Result<List<List<double>?>, Failure>> embedBoxes(
      String imagePath, List<RawBox> boxes) async {
    final out = <List<double>?>[];
    for (var i = 0; i < boxes.length; i++) {
      final b = boxes[i];
      final path = await writeBoxCrop(
        srcPath: imagePath,
        x1: b.x1,
        y1: b.y1,
        x2: b.x2,
        y2: b.y2,
        outName: 'embed_$i',
      );
      switch (await embed(path)) {
        case Ok(:final value):
          out.add(value);
        case Err():
          out.add(null);
      }
    }
    return Ok(out);
  }
}

/// In-memory nearest-neighbour index over enrolled SKU embeddings.
abstract class SkuIndex {
  /// Number of SKUs with at least one active vector.
  int get skuCount;
  bool get isEmpty => skuCount == 0;
  Future<void> refresh();
  List<SkuCandidate> topMatches(List<double> queryEmbedding, {int k = 3});
}
