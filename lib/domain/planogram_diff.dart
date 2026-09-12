/// PlanogramDiff — T-11.
///
/// Pure Dart service. Compares actual shelf facings (from FacingCounter) against
/// the planogram target and produces a [ShelfFact] per SKU.
///
/// Status rules (match ShelfStatus enum in models.dart):
///   - inStock   : counted >= target  (fully compliant)
///   - belowPlan : 0 < counted < target (partial stock)
///   - stockout  : counted == 0 AND sku was expected (in planogram)
///   - unlisted  : counted > 0 BUT sku NOT in planogram (unexpected facing)
///
/// Also flags any planogram SKU with zero counted facings that wasn''t
/// explicitly stockout (i.e., genuinely missing) as stockout.
///
/// Returns Result<List<ShelfFact>, Failure> — never throws.
library;

import 'package:uuid/uuid.dart';

import '../core/failures.dart';
import '../core/result.dart';
import '../domain/models/models.dart';

final class PlanogramDiff {
  const PlanogramDiff();

  static const _uuid = Uuid();

  /// Diff [counted] facings against [targets] planogram.
  ///
  /// [counted]  : skuId → facing count (from FacingCounter).
  /// [targets]  : skuId → target facings (from planogram / DB).
  /// [visitId]  : written into every [ShelfFact.visitId].
  /// [computedAt]: epoch ms; defaults to now.
  ///
  /// Fails with [DbFailure] if both maps are empty (nothing to diff).
  Result<List<ShelfFact>, Failure> diff({
    required Map<String, int> counted,
    required Map<String, int> targets,
    required String visitId,
    int? computedAt,
  }) {
    if (counted.isEmpty && targets.isEmpty) {
      return Err(const DbFailure('Cannot diff: both counted and targets are empty.'));
    }

    try {
      final ts = computedAt ?? DateTime.now().millisecondsSinceEpoch;
      final facts = <ShelfFact>[];

      // All SKUs in the planogram
      for (final entry in targets.entries) {
        final skuId  = entry.key;
        final target = entry.value;
        final actual = counted[skuId] ?? 0;

        final status = switch (actual) {
          0                           => ShelfStatus.stockout,
          _ when actual >= target     => ShelfStatus.inStock,
          _                           => ShelfStatus.belowPlan,
        };

        facts.add(ShelfFact(
          id: _uuid.v4(),
          visitId: visitId,
          skuId: skuId,
          detectedFacings: actual,
          targetFacings: target,
          status: status,
          computedAt: ts,
        ));
      }

      // SKUs detected on shelf but NOT in the planogram → unlisted
      final unplanned = counted.keys.where((id) => !targets.containsKey(id));
      for (final skuId in unplanned) {
        facts.add(ShelfFact(
          id: _uuid.v4(),
          visitId: visitId,
          skuId: skuId,
          detectedFacings: counted[skuId]!,
          targetFacings: 0,
          status: ShelfStatus.unlisted,
          computedAt: ts,
        ));
      }

      return Ok(facts);
    } catch (e, st) {
      return Err(DbFailure('PlanogramDiff failed: $e\n$st'));
    }
  }
}
