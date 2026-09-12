import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/ml/common/thresholds.dart';
import 'package:shelfsense/ml/embedder/sku_index.dart';
import 'package:shelfsense/ml/embedder/tflite_embedder.dart';

IndexedVector _v(String sku, List<double> xs) => IndexedVector(
      skuId: sku,
      skuName: 'Name $sku',
      skuCode: sku.toUpperCase(),
      grammageLabel: null,
      vector: Float32List.fromList(l2Normalise(xs)),
    );

void main() {
  group('rankCandidates', () {
    final index = [
      _v('a', [1, 0, 0]),
      _v('a', [0.9, 0.1, 0]), // second shot of the same SKU
      _v('b', [0, 1, 0]),
      _v('c', [0, 0, 1]),
    ];

    test('returns best score per SKU, sorted descending, top k', () {
      final r = rankCandidates(l2Normalise([1, 0.2, 0]), index, k: 2);
      expect(r.map((c) => c.skuId), ['a', 'b']);
      expect(r.first.confidence, greaterThan(r.last.confidence));
      // The better of SKU a's two shots is what counts.
      expect(r.first.confidence, closeTo(0.98, 0.02));
    });

    test('a SKU appears once even with many vectors', () {
      final r = rankCandidates([1, 0, 0], index, k: 10);
      expect(r.map((c) => c.skuId).toSet().length, r.length);
      expect(r, hasLength(3));
    });

    test('empty index yields no candidates', () {
      expect(rankCandidates([1, 0, 0], const [], k: 3), isEmpty);
    });

    test('carries SKU name/code/grammage through', () {
      final r = rankCandidates([0, 0, 1], index, k: 1).single;
      expect(r.skuId, 'c');
      expect(r.skuCode, 'C');
      expect(r.skuName, 'Name c');
    });
  });

  group('routeScore', () {
    test('uses the TRD bands', () {
      expect(routeScore(kMatchHigh), MatchRoute.accept);
      expect(routeScore(0.95), MatchRoute.accept);
      expect(routeScore(kMatchHigh - 0.01), MatchRoute.lowConfidence);
      expect(routeScore(kMatchLow), MatchRoute.lowConfidence);
      expect(routeScore(kMatchLow - 0.01), MatchRoute.unmatched);
      expect(routeScore(0), MatchRoute.unmatched);
    });
  });

  group('vector encoding', () {
    test('decodeVector round-trips a 128-d float32 blob', () {
      final v = Float32List.fromList(List.generate(128, (i) => i / 128));
      final blob = v.buffer.asUint8List();
      expect(blob.length, 512);
      final back = decodeVector(blob);
      expect(back.length, 128);
      expect(back[127], closeTo(127 / 128, 1e-6));
    });

    test('l2Normalise gives unit length and leaves zero alone', () {
      final n = l2Normalise([3, 4]);
      expect(n[0], closeTo(0.6, 1e-9));
      expect(n[1], closeTo(0.8, 1e-9));
      expect(l2Normalise([0, 0]), [0, 0]);
    });
  });
}
