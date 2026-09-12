/// FacingCounter — T-10.
///
/// Pure Dart service. Takes a list of [MatchedBox] produced by A's detector
/// pipeline and counts the number of facings (visible pack-fronts) per SKU.
///
/// Rules:
///   - Gap boxes (isGap: true) are never counted — they are empty shelf slots.
///   - Unmatched boxes (isMatched: false) are tallied separately as unknowns
///     so the caller can decide whether to surface them in the UI.
///   - A box on multiple shelf rows is still one facing (shelfRow is metadata
///     for layout, not for deduplication).
///
/// Returns Result<FacingCount, Failure> — never throws across the boundary.
library;

import '../core/failures.dart';
import '../core/result.dart';
import '../domain/models/models.dart';

/// Output of [FacingCounter.count].
class FacingCount {
  const FacingCount({
    required this.bySku,
    required this.unknownCount,
    required this.gapCount,
    required this.totalBoxes,
  });

  /// SKU ID → number of counted facings. Only matched SKUs appear here.
  final Map<String, int> bySku;

  /// Number of detected boxes that could not be matched to any SKU.
  final int unknownCount;

  /// Number of gap (empty slot) boxes detected.
  final int gapCount;

  /// Total detected boxes (matched + unknown + gap).
  final int totalBoxes;

  /// Convenience: total matched facings across all SKUs.
  int get matchedFacings => bySku.values.fold(0, (s, v) => s + v);

  @override
  String toString() =>
      'FacingCount(skus=${bySku.length}, matched=$matchedFacings, '
      'unknown=$unknownCount, gaps=$gapCount)';
}

/// Counts facings from a list of [MatchedBox] detections.
///
/// Stateless — safe to call from any isolate or async context.
final class FacingCounter {
  const FacingCounter();

  /// Count facings from [boxes].
  ///
  /// Returns [ExportFailed] when [boxes] is empty (nothing was detected).
  /// All real errors are wrapped — never throws.
  Result<FacingCount, Failure> count(List<MatchedBox> boxes) {
    if (boxes.isEmpty) {
      return Err(
        const DetectorInferenceFailed(
          'No boxes to count — detector returned empty result.',
        ),
      );
    }

    try {
      final bySku = <String, int>{};
      int unknownCount = 0;
      int gapCount = 0;

      for (final box in boxes) {
        if (box.isGap) {
          gapCount++;
          continue;
        }
        if (!box.isMatched || box.skuId == null) {
          unknownCount++;
          continue;
        }
        bySku[box.skuId!] = (bySku[box.skuId!] ?? 0) + 1;
      }

      return Ok(
        FacingCount(
          bySku: Map.unmodifiable(bySku),
          unknownCount: unknownCount,
          gapCount: gapCount,
          totalBoxes: boxes.length,
        ),
      );
    } catch (e, st) {
      return Err(DetectorInferenceFailed('FacingCounter failed: $e\n$st'));
    }
  }
}
