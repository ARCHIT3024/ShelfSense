/// ReorderEngine — T-12.
///
/// Pure Dart service. Takes [ShelfFact] list (from PlanogramDiff) + [Sku]
/// catalogue and produces a suggested [OrderLine] list for the rep to review.
///
/// Ordering logic:
///   - Only [ShelfStatus.belowPlan] and [ShelfStatus.stockout] facts generate
///     a line. inStock and unlisted facts are ignored.
///   - suggestedQty = ceil(deficit / caseSize). Always in whole cases.
///   - finalQty starts equal to suggestedQty (wasOverridden: false).
///     The rep edits finalQty in the UI; wasOverridden flips to true there.
///   - valuePaise = finalQty * mrpPaise. Rupee rounding stays in paise.
///   - SKUs not found in the catalogue are skipped with a warning log.
///
/// Returns Result<List<OrderLine>, Failure> — never throws.
library;

import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../core/failures.dart';
import '../core/logger.dart';
import '../core/result.dart';
import '../domain/models/models.dart';

const _tag = 'ReorderEngine';

final class ReorderEngine {
  const ReorderEngine();

  static const _uuid = Uuid();

  /// Suggest order quantities for all under-stocked SKUs.
  ///
  /// [facts]   : output of PlanogramDiff (one entry per SKU).
  /// [skus]    : full SKU catalogue; used for mrpPaise, caseSize, name, code.
  /// [visitId] : written into every [OrderLine.visitId].
  ///
  /// Returns an empty list (Ok([])) when there is nothing to reorder.
  /// Returns [DbFailure] only if [facts] itself is null — should never happen
  /// in practice.
  Result<List<OrderLine>, Failure> suggest({
    required List<ShelfFact> facts,
    required List<Sku> skus,
    required String visitId,
  }) {
    try {
      // Index the SKU catalogue by id for O(1) lookup.
      final skuById = {for (final s in skus) s.id: s};

      final lines = <OrderLine>[];

      for (final fact in facts) {
        // Only reorder what is actually short.
        if (fact.status != ShelfStatus.belowPlan &&
            fact.status != ShelfStatus.stockout) {
          continue;
        }

        final sku = skuById[fact.skuId];
        if (sku == null) {
          AppLogger.w(
            _tag,
            'SKU ${fact.skuId} in ShelfFact not found in catalogue — skipping.',
          );
          continue;
        }

        final deficit = fact.targetFacings - fact.detectedFacings;
        if (deficit <= 0) continue; // safety: status was wrong

        // Round up to whole cases.
        final suggestedQty =
            (deficit / sku.caseSize).ceil() * sku.caseSize;

        final valuePaise = suggestedQty * sku.mrpPaise;

        lines.add(OrderLine(
          id: _uuid.v4(),
          visitId: visitId,
          skuId: sku.id,
          skuName: sku.name,
          skuCode: sku.code,
          grammageLabel: sku.grammageLabel,
          mrpPaise: sku.mrpPaise,
          caseSize: sku.caseSize,
          suggestedQty: suggestedQty,
          finalQty: suggestedQty, // rep edits this; wasOverridden flips in UI
          unit: 'case',
          valuePaise: valuePaise,
          wasOverridden: false,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }

      // Sort: stockouts first (most urgent), then by SKU name for readability.
      lines.sort((a, b) {
        final aFact = facts.firstWhere((f) => f.skuId == a.skuId);
        final bFact = facts.firstWhere((f) => f.skuId == b.skuId);
        if (aFact.status == ShelfStatus.stockout &&
            bFact.status != ShelfStatus.stockout) return -1;
        if (bFact.status == ShelfStatus.stockout &&
            aFact.status != ShelfStatus.stockout) return 1;
        return (a.skuName ?? '').compareTo(b.skuName ?? '');
      });

      AppLogger.i(_tag,
          'Suggested ${lines.length} reorder line(s) for visit $visitId');
      return Ok(lines);
    } catch (e, st) {
      return Err(DbFailure('ReorderEngine failed: $e\n$st'));
    }
  }
}
