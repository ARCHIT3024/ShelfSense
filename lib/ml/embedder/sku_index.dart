/// T-20 — in-memory nearest-neighbour index over enrolled SKU embeddings.
///
/// ~40 SKUs × 8 shots = 320 vectors; brute-force cosine is microseconds.
/// Scoring and threshold routing are pure functions (unit-tested); only
/// [InMemorySkuIndex.refresh] touches drift.
library;

import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../../core/logger.dart';
import '../../data/db/database.dart';
import '../../domain/models/models.dart';
import '../common/thresholds.dart';
import 'embedder_service.dart';

const _tag = 'SkuIndex';

/// One enrolled vector and the SKU it belongs to.
class IndexedVector {
  const IndexedVector({
    required this.skuId,
    required this.skuName,
    required this.skuCode,
    required this.grammageLabel,
    required this.vector,
  });
  final String skuId, skuName, skuCode;
  final String? grammageLabel;
  final Float32List vector; // L2-normalised
}

/// Cosine (= dot product on unit vectors) of [query] against every vector,
/// best score per SKU, sorted descending, top [k].
List<SkuCandidate> rankCandidates(
  List<double> query,
  List<IndexedVector> vectors, {
  int k = 3,
}) {
  final best = <String, ({IndexedVector v, double score})>{};
  for (final iv in vectors) {
    final n = iv.vector.length < query.length ? iv.vector.length : query.length;
    var dot = 0.0;
    for (var i = 0; i < n; i++) {
      dot += iv.vector[i] * query[i];
    }
    final prev = best[iv.skuId];
    if (prev == null || dot > prev.score) best[iv.skuId] = (v: iv, score: dot);
  }
  final ranked = best.values.toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return [
    for (final r in ranked.take(k))
      SkuCandidate(
        skuId: r.v.skuId,
        skuName: r.v.skuName,
        skuCode: r.v.skuCode,
        confidence: r.score.clamp(0.0, 1.0),
        grammageLabel: r.v.grammageLabel,
      ),
  ];
}

/// Threshold routing (TRD §4.1): what a top score means for a box.
enum MatchRoute { accept, lowConfidence, unmatched }

MatchRoute routeScore(double score,
        {double high = kMatchHigh, double low = kMatchLow}) =>
    score >= high
        ? MatchRoute.accept
        : score >= low
            ? MatchRoute.lowConfidence
            : MatchRoute.unmatched;

/// 128 × float32 little-endian blob ↔ vector (05_DATA_SCHEMA §4).
Float32List decodeVector(Uint8List blob) =>
    blob.buffer.asFloat32List(blob.offsetInBytes, blob.lengthInBytes ~/ 4);

class InMemorySkuIndex implements SkuIndex {
  InMemorySkuIndex(this.db);
  final AppDatabase db;

  List<IndexedVector> _vectors = const [];
  int _skuCount = 0;

  @override
  int get skuCount => _skuCount;

  @override
  bool get isEmpty => _skuCount == 0;

  int get vectorCount => _vectors.length;

  @override
  Future<void> refresh() async {
    final rows = await (db.select(db.skuEmbeddings).join([
      innerJoin(db.skus, db.skus.id.equalsExp(db.skuEmbeddings.skuId)),
    ])
          ..where(db.skuEmbeddings.isActive.equals(true) &
              db.skus.isActive.equals(true)))
        .get();
    final vectors = <IndexedVector>[];
    for (final r in rows) {
      final e = r.readTable(db.skuEmbeddings);
      final s = r.readTable(db.skus);
      vectors.add(IndexedVector(
        skuId: s.id,
        skuName: s.name,
        skuCode: s.code,
        grammageLabel: _grammage(s),
        vector: decodeVector(Uint8List.fromList(e.vector)),
      ));
    }
    _vectors = vectors;
    _skuCount = vectors.map((v) => v.skuId).toSet().length;
    AppLogger.i(_tag, 'Index: ${vectors.length} vectors over $_skuCount SKUs');
  }

  @override
  List<SkuCandidate> topMatches(List<double> queryEmbedding, {int k = 3}) =>
      rankCandidates(queryEmbedding, _vectors, k: k);
}

// Same formatting as the SKU picker sheet.
String? _grammage(SkusData s) {
  final v = s.grammageValue;
  if (v == null) return null;
  final disp = v == v.floorToDouble() ? v.toInt().toString() : v.toString();
  return '$disp ${s.grammageUnit ?? ''}'.trim();
}
