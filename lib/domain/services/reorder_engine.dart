/// ReorderEngine — T-18 (part of L0, wired in T-19).
///
/// Pure Dart service. Takes [ShelfFact] list (from PlanogramDiff) + [Sku]
/// catalogue + trailing order history, and produces a suggested [OrderLine]
/// list for the rep to review.
///
/// Formula (TRD §5.4):
///   base      = max(0, target_facings − detected_facings)
///   trailing  = median of last 3 confirmed final_qty for this store+sku (0 if none)
///   suggested = round_to_case(max(base, trailing × 0.8))
///   capped    = min(suggested, target_facings × 2)   // never propose absurd qty
///
/// Ordering: only belowPlan and stockout facts generate lines.
/// Sort: stockouts first, then alphabetical by skuName.
///
/// Returns `Result<List<OrderLine>, Failure>` — never throws.
library;

import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../../core/failures.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../models/models.dart';

const _tag = 'ReorderEngine';

final class ReorderEngine {
  const ReorderEngine();

  static const _uuid = Uuid();

  /// Suggest order quantities for all under-stocked SKUs.
  ///
  /// [facts]       : output of PlanogramDiff (one entry per SKU).
  /// [skus]        : full SKU catalogue keyed for mrpPaise, caseSize, name, code.
  /// [visitId]     : written into every [OrderLine.visitId].
  /// [trailingQty] : skuId → median of last 3 confirmed final_qty for this
  ///                 store+sku. Pass an empty map when no history exists.
  ///                 Populated by the caller (Riverpod provider) from Drift.
  ///
  /// Returns Ok([]) — never Err — when there is nothing to reorder.
  Result<List<OrderLine>, Failure> suggest({
    required List<ShelfFact> facts,
    required List<Sku> skus,
    required String visitId,
    Map<String, int> trailingQty = const {},
  }) {
    try {
      final skuById = {for (final s in skus) s.id: s};
      final lines = <OrderLine>[];

      for (final fact in facts) {
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

        final base = math.max(0, fact.targetFacings - fact.detectedFacings);
        if (base <= 0) continue; // safety — status was mis-set upstream

        // TRD §5.4 trailing floor: if the rep historically ordered more, respect that.
        final trailing = trailingQty[fact.skuId] ?? 0;
        final raw = math.max(base.toDouble(), trailing * 0.8);

        // Round up to whole cases (TRD: round_to_case).
        final rounded =
            ((raw / sku.caseSize).ceil() * sku.caseSize).toInt();

        // Cap: never propose more than 2× the planogram target (TRD §5.4).
        final capped = math.min(rounded, fact.targetFacings * 2);

        final suggestedQty = math.max(capped, sku.caseSize); // at least 1 case
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

      // Sort: stockouts first (most urgent), then alphabetical by SKU name.
      lines.sort((a, b) {
        final aFact = facts.firstWhere((f) => f.skuId == a.skuId);
        final bFact = facts.firstWhere((f) => f.skuId == b.skuId);
        if (aFact.status == ShelfStatus.stockout &&
            bFact.status != ShelfStatus.stockout) {
          return -1;
        }
        if (bFact.status == ShelfStatus.stockout &&
            aFact.status != ShelfStatus.stockout) {
          return 1;
        }
        return (a.skuName ?? '').compareTo(b.skuName ?? '');
      });

      AppLogger.i(
          _tag, 'Suggested ${lines.length} reorder line(s) for visit $visitId');
      return Ok(lines);
    } catch (e, st) {
      return Err(DbFailure('ReorderEngine failed: $e\n$st'));
    }
  }
}

// ---------------------------------------------------------------------------
// Utility — exposed for testing
// ---------------------------------------------------------------------------

/// Returns the median of [values], or 0 if the list is empty.
/// Used by the Riverpod provider to compute [trailingQty] from DB rows.
int medianOrZero(List<int> values) {
  if (values.isEmpty) return 0;
  final sorted = [...values]..sort();
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[mid]
      : ((sorted[mid - 1] + sorted[mid]) / 2).round();
}
