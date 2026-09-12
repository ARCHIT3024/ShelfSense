/// Unit tests for FacingCounter — T-10.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/core/failures.dart';
import 'package:shelfsense/core/result.dart';
import 'package:shelfsense/domain/services/facing_counter.dart';
import 'package:shelfsense/domain/models/models.dart';

void main() {
  const counter = FacingCounter();

  // ── Helpers ────────────────────────────────────────────────────────────────

  MatchedBox box({
    required String id,
    String? skuId,
    bool isGap = false,
    bool wasCorrected = false,
    MatchMethod method = MatchMethod.embedding,
  }) =>
      MatchedBox(
        id: id,
        box: const RawBox(x1: 0, y1: 0, x2: 0.1, y2: 0.1, score: 0.9),
        detConfidence: 0.9,
        skuId: skuId,
        method: skuId != null ? method : MatchMethod.unmatched,
        isGap: isGap,
        wasCorrected: wasCorrected,
      );

  // ── Empty input ────────────────────────────────────────────────────────────

  group('empty input', () {
    test('returns Err when boxes list is empty', () {
      final result = counter.count([]);
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<DetectorInferenceFailed>());
    });
  });

  // ── Single SKU ─────────────────────────────────────────────────────────────

  group('single SKU', () {
    test('one matched box → bySku has count 1', () {
      final result = counter.count([box(id: '1', skuId: 'SKU-A')]);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.bySku['SKU-A'], 1);
    });

    test('three matched boxes same SKU → count 3', () {
      final result = counter.count([
        box(id: '1', skuId: 'SKU-A'),
        box(id: '2', skuId: 'SKU-A'),
        box(id: '3', skuId: 'SKU-A'),
      ]);
      expect(result.valueOrNull!.bySku['SKU-A'], 3);
    });
  });

  // ── Multiple SKUs ──────────────────────────────────────────────────────────

  group('multiple SKUs', () {
    test('two different SKUs counted independently', () {
      final result = counter.count([
        box(id: '1', skuId: 'SKU-A'),
        box(id: '2', skuId: 'SKU-B'),
        box(id: '3', skuId: 'SKU-A'),
      ]);
      final c = result.valueOrNull!;
      expect(c.bySku['SKU-A'], 2);
      expect(c.bySku['SKU-B'], 1);
    });

    test('matchedFacings equals sum of all counts', () {
      final result = counter.count([
        box(id: '1', skuId: 'SKU-A'),
        box(id: '2', skuId: 'SKU-B'),
        box(id: '3', skuId: 'SKU-A'),
        box(id: '4', skuId: 'SKU-C'),
      ]);
      expect(result.valueOrNull!.matchedFacings, 4);
    });
  });

  // ── Gap boxes ──────────────────────────────────────────────────────────────

  group('gap boxes', () {
    test('gap boxes are not counted as facings', () {
      final result = counter.count([
        box(id: '1', skuId: 'SKU-A'),
        box(id: '2', isGap: true),  // gap — must not be counted
      ]);
      final c = result.valueOrNull!;
      expect(c.bySku['SKU-A'], 1);
      expect(c.gapCount, 1);
      expect(c.bySku.containsKey(null), isFalse);
    });

    test('all gaps → bySku is empty, gapCount reflects total', () {
      final result = counter.count([
        box(id: '1', isGap: true),
        box(id: '2', isGap: true),
      ]);
      final c = result.valueOrNull!;
      expect(c.bySku.isEmpty, isTrue);
      expect(c.gapCount, 2);
      expect(c.matchedFacings, 0);
    });
  });

  // ── Unmatched boxes ────────────────────────────────────────────────────────

  group('unmatched boxes', () {
    test('unmatched boxes increment unknownCount not bySku', () {
      final result = counter.count([
        box(id: '1', skuId: 'SKU-A'),
        box(id: '2'),  // no skuId → unmatched
      ]);
      final c = result.valueOrNull!;
      expect(c.bySku.length, 1);
      expect(c.unknownCount, 1);
    });
  });

  // ── totalBoxes ─────────────────────────────────────────────────────────────

  group('totalBoxes', () {
    test('totalBoxes = matched + unknown + gap', () {
      final result = counter.count([
        box(id: '1', skuId: 'SKU-A'),   // matched
        box(id: '2'),                    // unknown
        box(id: '3', isGap: true),       // gap
      ]);
      expect(result.valueOrNull!.totalBoxes, 3);
    });
  });

  // ── bySku is unmodifiable ──────────────────────────────────────────────────

  test('bySku map is unmodifiable', () {
    final result = counter.count([box(id: '1', skuId: 'SKU-A')]);
    final map = result.valueOrNull!.bySku;
    expect(() => map['NEW'] = 99, throwsUnsupportedError);
  });

  // ── Smoke test ─────────────────────────────────────────────────────────────

  test('smoke: realistic shelf scan with 3 SKUs + 2 gaps + 1 unknown', () {
    final boxes = [
      box(id: 'b1', skuId: 'NMK-200'),
      box(id: 'b2', skuId: 'NMK-200'),
      box(id: 'b3', skuId: 'BIS-100'),
      box(id: 'b4', isGap: true),
      box(id: 'b5', skuId: 'CHP-050'),
      box(id: 'b6'),           // unknown
      box(id: 'b7', isGap: true),
      box(id: 'b8', skuId: 'NMK-200'),
    ];
    final c = counter.count(boxes).valueOrNull!;
    expect(c.bySku['NMK-200'], 3);
    expect(c.bySku['BIS-100'], 1);
    expect(c.bySku['CHP-050'], 1);
    expect(c.gapCount, 2);
    expect(c.unknownCount, 1);
    expect(c.totalBoxes, 8);
    expect(c.matchedFacings, 5);
  });
}
