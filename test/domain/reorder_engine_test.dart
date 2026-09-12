/// Unit tests for ReorderEngine — T-12.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/core/result.dart';
import 'package:shelfsense/domain/models/models.dart';
import 'package:shelfsense/domain/services/reorder_engine.dart';

void main() {
  const engine = ReorderEngine();
  const visitId = 'visit-re-001';
  const ts = 1000000;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Sku sku({
    required String id,
    required String code,
    required String name,
    int mrpPaise = 4500,
    int caseSize = 12,
  }) =>
      Sku(
        id: id, code: code, name: name,
        mrpPaise: mrpPaise, caseSize: caseSize,
        isEnrolled: true, isActive: true,
        createdAt: ts,
      );

  ShelfFact fact({
    required String skuId,
    required ShelfStatus status,
    int detected = 0,
    int target = 4,
  }) =>
      ShelfFact(
        id: 'fact-$skuId',
        visitId: visitId,
        skuId: skuId,
        detectedFacings: detected,
        targetFacings: target,
        status: status,
        computedAt: ts,
      );

  // ── Empty / no-reorder cases ───────────────────────────────────────────────

  group('no reorder needed', () {
    test('inStock facts produce no order lines', () {
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.inStock, detected: 4, target: 4)],
        skus: [sku(id: 'A', code: 'SKU-A', name: 'SKU A')],
        visitId: visitId,
      );
      expect(result.isOk, isTrue);
      expect(result.valueOrNull!, isEmpty);
    });

    test('unlisted facts produce no order lines', () {
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.unlisted, detected: 3, target: 0)],
        skus: [sku(id: 'A', code: 'SKU-A', name: 'SKU A')],
        visitId: visitId,
      );
      expect(result.valueOrNull!, isEmpty);
    });

    test('empty facts list returns Ok with empty list', () {
      final result = engine.suggest(facts: [], skus: [], visitId: visitId);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull!, isEmpty);
    });
  });

  // ── suggestedQty: whole-case rounding ─────────────────────────────────────

  group('suggestedQty rounding', () {
    test('deficit exactly divisible by caseSize', () {
      // deficit = 4 - 0 = 4, caseSize = 4 → 1 case = 4 units
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
        visitId: visitId,
      );
      expect(result.valueOrNull!.single.suggestedQty, 4);
    });

    test('deficit rounds UP to next full case', () {
      // deficit = 5, caseSize = 4 → ceil(5/4)*4 = 8
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 5)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
        visitId: visitId,
      );
      expect(result.valueOrNull!.single.suggestedQty, 8);
    });

    test('deficit of 1 unit rounds up to one full case', () {
      // deficit = 1, caseSize = 12 → ceil(1/12)*12 = 12
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.belowPlan, detected: 3, target: 4)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 12)],
        visitId: visitId,
      );
      expect(result.valueOrNull!.single.suggestedQty, 12);
    });
  });

  // ── valuePaise = qty × mrpPaise ───────────────────────────────────────────

  group('valuePaise', () {
    test('valuePaise = suggestedQty * mrpPaise', () {
      // deficit 4, caseSize 4 → qty = 4, mrpPaise = 4500 → value = 18000
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4)],
        skus: [sku(id: 'A', code: 'A', name: 'A', mrpPaise: 4500, caseSize: 4)],
        visitId: visitId,
      );
      final line = result.valueOrNull!.single;
      expect(line.valuePaise, line.suggestedQty * 4500);
    });
  });

  // ── wasOverridden starts false ────────────────────────────────────────────

  test('all suggested lines have wasOverridden: false', () {
    final result = engine.suggest(
      facts: [
        fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4),
        fact(skuId: 'B', status: ShelfStatus.belowPlan, detected: 2, target: 6),
      ],
      skus: [
        sku(id: 'A', code: 'A', name: 'A'),
        sku(id: 'B', code: 'B', name: 'B'),
      ],
      visitId: visitId,
    );
    for (final line in result.valueOrNull!) {
      expect(line.wasOverridden, isFalse);
    }
  });

  // ── finalQty == suggestedQty initially ───────────────────────────────────

  test('finalQty starts equal to suggestedQty', () {
    final result = engine.suggest(
      facts: [fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4)],
      skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
      visitId: visitId,
    );
    final line = result.valueOrNull!.single;
    expect(line.finalQty, line.suggestedQty);
  });

  // ── SKU not in catalogue ──────────────────────────────────────────────────

  test('fact skuId missing from catalogue → skipped silently', () {
    final result = engine.suggest(
      facts: [fact(skuId: 'GHOST', status: ShelfStatus.stockout, detected: 0, target: 4)],
      skus: [], // empty catalogue
      visitId: visitId,
    );
    expect(result.isOk, isTrue);
    expect(result.valueOrNull!, isEmpty);
  });

  // ── Sort order: stockouts first ───────────────────────────────────────────

  test('stockout lines appear before belowPlan lines', () {
    final result = engine.suggest(
      facts: [
        fact(skuId: 'B', status: ShelfStatus.belowPlan, detected: 2, target: 6),
        fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4),
      ],
      skus: [
        sku(id: 'A', code: 'A', name: 'Alpha', caseSize: 4),
        sku(id: 'B', code: 'B', name: 'Beta', caseSize: 4),
      ],
      visitId: visitId,
    );
    final lines = result.valueOrNull!;
    expect(lines.first.skuId, 'A'); // stockout → first
    expect(lines.last.skuId, 'B');  // belowPlan → after
  });

  // ── visitId propagation ───────────────────────────────────────────────────

  test('all lines carry the given visitId', () {
    final result = engine.suggest(
      facts: [
        fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4),
        fact(skuId: 'B', status: ShelfStatus.belowPlan, detected: 1, target: 4),
      ],
      skus: [
        sku(id: 'A', code: 'A', name: 'A', caseSize: 4),
        sku(id: 'B', code: 'B', name: 'B', caseSize: 4),
      ],
      visitId: 'MY-VISIT',
    );
    for (final line in result.valueOrNull!) {
      expect(line.visitId, 'MY-VISIT');
    }
  });

  // ── Smoke test ─────────────────────────────────────────────────────────────

  test('smoke: realistic 3-SKU shelf with mixed statuses', () {
    final result = engine.suggest(
      facts: [
        fact(skuId: 'NMK', status: ShelfStatus.inStock,   detected: 4, target: 4),
        fact(skuId: 'BIS', status: ShelfStatus.stockout,  detected: 0, target: 6),
        fact(skuId: 'CHP', status: ShelfStatus.belowPlan, detected: 2, target: 8),
        fact(skuId: 'UNL', status: ShelfStatus.unlisted,  detected: 3, target: 0),
      ],
      skus: [
        sku(id: 'NMK', code: 'NMK', name: 'Namkeen 200g', mrpPaise: 4500, caseSize: 12),
        sku(id: 'BIS', code: 'BIS', name: 'Biscuit 100g', mrpPaise: 1000, caseSize: 24),
        sku(id: 'CHP', code: 'CHP', name: 'Chips 50g',    mrpPaise: 2000, caseSize: 6),
        sku(id: 'UNL', code: 'UNL', name: 'Unlisted SKU', mrpPaise: 500,  caseSize: 10),
      ],
      visitId: visitId,
    );

    expect(result.isOk, isTrue);
    final lines = result.valueOrNull!;

    // Only BIS (stockout) and CHP (belowPlan) should generate lines
    expect(lines.length, 2);

    // BIS: deficit=6, caseSize=24 → ceil(6/24)*24 = 24 units
    final bis = lines.firstWhere((l) => l.skuId == 'BIS');
    expect(bis.suggestedQty, 24);

    // CHP: deficit=6, caseSize=6 → ceil(6/6)*6 = 6 units
    final chp = lines.firstWhere((l) => l.skuId == 'CHP');
    expect(chp.suggestedQty, 6);

    // BIS is stockout → should be first
    expect(lines.first.skuId, 'BIS');
  });

  // ── Trailing history floor (TRD §5.4) ────────────────────────────────────

  group('trailing history floor', () {
    test('trailing x 0.8 floor used when it exceeds base deficit', () {
      // deficit = 4 - 2 = 2, trailing = 20  -> floor = 20 x 0.8 = 16
      // ceil(16/4)*4 = 16 -> suggestedQty = 16
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.belowPlan, detected: 2, target: 4)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
        visitId: visitId,
        trailingQty: {'A': 20},
      );
      expect(result.valueOrNull!.single.suggestedQty, 8); // cap(target*2=8) < trailing floor(16) -> 8
    });

    test('base deficit used when it exceeds trailing x 0.8', () {
      // deficit = 4, trailing = 2  -> 2x0.8=1.6; base 4 wins  -> qty=4
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
        visitId: visitId,
        trailingQty: {'A': 2},
      );
      expect(result.valueOrNull!.single.suggestedQty, 4);
    });

    test('no trailingQty entry treats trailing as 0 and base wins', () {
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 4)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
        visitId: visitId,
      );
      expect(result.valueOrNull!.single.suggestedQty, 4);
    });
  });

  // ── Absurd-qty cap: min(suggested, target x 2) (TRD §5.4) ───────────────

  group('absurd-quantity cap', () {
    test('cap at target_facings x 2 when trailing is huge', () {
      // trailing=200 -> 200x0.8=160; ceil(160/4)*4=160; cap=4x2=8 -> qty<=8
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.belowPlan, detected: 2, target: 4)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
        visitId: visitId,
        trailingQty: {'A': 200},
      );
      expect(result.valueOrNull!.single.suggestedQty, lessThanOrEqualTo(8));
    });

    test('minimum is always one full case even under a tight cap', () {
      // target=1, cap=2; caseSize=4 -> at least 4 units (one case)
      final result = engine.suggest(
        facts: [fact(skuId: 'A', status: ShelfStatus.stockout, detected: 0, target: 1)],
        skus: [sku(id: 'A', code: 'A', name: 'A', caseSize: 4)],
        visitId: visitId,
      );
      expect(result.valueOrNull!.single.suggestedQty, greaterThanOrEqualTo(4));
    });
  });

  // ── medianOrZero helper ────────────────────────────────────────────────────

  group('medianOrZero', () {
    test('empty list -> 0', () => expect(medianOrZero([]), 0));
    test('single value -> that value', () => expect(medianOrZero([10]), 10));
    test('odd length -> middle element', () => expect(medianOrZero([3, 1, 2]), 2));
    test('even length -> mean of two middles', () => expect(medianOrZero([1, 3, 5, 7]), 4));
    test('unsorted input sorted before median', () => expect(medianOrZero([9, 1, 5]), 5));
  });
}

