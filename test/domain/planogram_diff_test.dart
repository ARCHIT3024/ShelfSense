/// Unit tests for PlanogramDiff — T-11.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/core/failures.dart';
import 'package:shelfsense/core/result.dart';
import 'package:shelfsense/domain/models/models.dart';
import 'package:shelfsense/domain/services/planogram_diff.dart';

void main() {
  const diff = PlanogramDiff();
  const visitId = 'visit-test-001';
  const ts = 1000000;

  // ── Guard ──────────────────────────────────────────────────────────────────

  group('empty guard', () {
    test('returns DbFailure when both maps are empty', () {
      final result = diff.diff(
        counted: {},
        targets: {},
        visitId: visitId,
        computedAt: ts,
      );
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<DbFailure>());
    });

    test('ok with empty counted but non-empty targets (all stockout)', () {
      final result = diff.diff(
        counted: {},
        targets: {'SKU-A': 4},
        visitId: visitId,
        computedAt: ts,
      );
      expect(result.isOk, isTrue);
    });

    test('ok with non-empty counted but empty targets (all unlisted)', () {
      final result = diff.diff(
        counted: {'SKU-X': 3},
        targets: {},
        visitId: visitId,
        computedAt: ts,
      );
      expect(result.isOk, isTrue);
    });
  });

  // ── inStock ────────────────────────────────────────────────────────────────

  group('ShelfStatus.inStock', () {
    test('counted == target → inStock', () {
      final result = diff.diff(
        counted: {'SKU-A': 4},
        targets: {'SKU-A': 4},
        visitId: visitId,
        computedAt: ts,
      );
      final fact = result.valueOrNull!.single;
      expect(fact.status, ShelfStatus.inStock);
      expect(fact.detectedFacings, 4);
      expect(fact.targetFacings, 4);
    });

    test('counted > target → inStock (over-stocked is still compliant)', () {
      final result = diff.diff(
        counted: {'SKU-A': 7},
        targets: {'SKU-A': 4},
        visitId: visitId,
        computedAt: ts,
      );
      expect(result.valueOrNull!.single.status, ShelfStatus.inStock);
    });
  });

  // ── belowPlan ─────────────────────────────────────────────────────────────

  group('ShelfStatus.belowPlan', () {
    test('0 < counted < target → belowPlan', () {
      final result = diff.diff(
        counted: {'SKU-A': 2},
        targets: {'SKU-A': 4},
        visitId: visitId,
        computedAt: ts,
      );
      final fact = result.valueOrNull!.single;
      expect(fact.status, ShelfStatus.belowPlan);
      expect(fact.detectedFacings, 2);
    });
  });

  // ── stockout ──────────────────────────────────────────────────────────────

  group('ShelfStatus.stockout', () {
    test('counted == 0, in targets → stockout', () {
      final result = diff.diff(
        counted: {},
        targets: {'SKU-A': 4},
        visitId: visitId,
        computedAt: ts,
      );
      final fact = result.valueOrNull!.single;
      expect(fact.status, ShelfStatus.stockout);
      expect(fact.detectedFacings, 0);
      expect(fact.targetFacings, 4);
    });
  });

  // ── unlisted ──────────────────────────────────────────────────────────────

  group('ShelfStatus.unlisted', () {
    test('counted > 0 but not in targets → unlisted', () {
      final result = diff.diff(
        counted: {'SKU-X': 3},
        targets: {},
        visitId: visitId,
        computedAt: ts,
      );
      final fact = result.valueOrNull!.single;
      expect(fact.status, ShelfStatus.unlisted);
      expect(fact.detectedFacings, 3);
      expect(fact.targetFacings, 0);
    });
  });

  // ── visitId & computedAt propagation ──────────────────────────────────────

  group('metadata propagation', () {
    test('all facts carry the given visitId', () {
      final result = diff.diff(
        counted: {'SKU-A': 2, 'SKU-B': 4},
        targets: {'SKU-A': 4, 'SKU-B': 4},
        visitId: 'MY-VISIT',
        computedAt: ts,
      );
      for (final f in result.valueOrNull!) {
        expect(f.visitId, 'MY-VISIT');
      }
    });

    test('all facts carry the given computedAt timestamp', () {
      final result = diff.diff(
        counted: {'SKU-A': 2},
        targets: {'SKU-A': 4},
        visitId: visitId,
        computedAt: 999888777,
      );
      expect(result.valueOrNull!.single.computedAt, 999888777);
    });

    test('each fact has a unique id (uuid v4)', () {
      final result = diff.diff(
        counted: {'SKU-A': 2, 'SKU-B': 1},
        targets: {'SKU-A': 4, 'SKU-B': 4},
        visitId: visitId,
        computedAt: ts,
      );
      final ids = result.valueOrNull!.map((f) => f.id).toList();
      expect(ids.toSet().length, ids.length); // all unique
    });
  });

  // ── Mixed scenario ─────────────────────────────────────────────────────────

  test('smoke: mixed statuses in one call', () {
    final result = diff.diff(
      counted: {
        'NMK-200': 4,   // exactly at plan → inStock
        'BIS-100': 2,   // below plan (target 6) → belowPlan
        'CHP-050': 0,   // in targets but 0 counted → handled as absent
        'UNLISTED': 2,  // not in targets → unlisted
      },
      targets: {
        'NMK-200': 4,
        'BIS-100': 6,
        'CHP-050': 3,
        'MISSING': 5,   // in targets but no count at all → stockout
      },
      visitId: visitId,
      computedAt: ts,
    );

    expect(result.isOk, isTrue);
    final facts = result.valueOrNull!;

    ShelfFact factFor(String skuId) =>
        facts.firstWhere((f) => f.skuId == skuId);

    expect(factFor('NMK-200').status, ShelfStatus.inStock);
    expect(factFor('BIS-100').status, ShelfStatus.belowPlan);
    // CHP-050 counted 0 — that means stockout
    expect(factFor('CHP-050').status, ShelfStatus.stockout);
    expect(factFor('MISSING').status, ShelfStatus.stockout);
    expect(factFor('UNLISTED').status, ShelfStatus.unlisted);
    expect(facts.length, 5); // 4 from targets + 1 unlisted
  });
}
