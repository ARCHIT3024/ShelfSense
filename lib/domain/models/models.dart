/// Pure Dart domain models — no drift imports.
/// These are the objects that flow between services and UI.
library;

// -----------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------

enum VisitStatus { draft, confirmed, exported }

enum ShelfStatus { inStock, belowPlan, stockout, unlisted }

enum MatchMethod { embedding, ocrTiebreak, manual, unmatched }

enum PlanogramSource { manual, history, defaultPlan }

enum ModelKind { detector, embedder, llm, asr, ocr }

// -----------------------------------------------------------------------
// Value objects
// -----------------------------------------------------------------------

/// A single detected bounding box, normalised 0-1 to the original image.
class RawBox {
  const RawBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.score,
  });
  final double x1, y1, x2, y2, score;

  double get width => x2 - x1;
  double get height => y2 - y1;
  double get area => width * height;
  double get cx => (x1 + x2) / 2;
  double get cy => (y1 + y2) / 2;
}

/// A box after the full pipeline has run.
class MatchedBox {
  const MatchedBox({
    required this.id,
    required this.box,
    required this.detConfidence,
    this.skuId,
    this.skuName,
    this.skuCode,
    this.matchConfidence,
    required this.method,
    this.shelfRow,
    required this.isGap,
    required this.wasCorrected,
    this.topCandidates = const [],
  });
  final String id;
  final RawBox box;
  final double detConfidence;
  final String? skuId, skuName, skuCode;
  final double? matchConfidence;
  final MatchMethod method;
  final int? shelfRow;
  final bool isGap;
  final bool wasCorrected;
  final List<SkuCandidate> topCandidates;

  bool get isMatched => skuId != null && method != MatchMethod.unmatched;
  bool get isLowConfidence =>
      matchConfidence != null && matchConfidence! < 0.72 && isMatched;
}

class SkuCandidate {
  const SkuCandidate({
    required this.skuId,
    required this.skuName,
    required this.skuCode,
    required this.confidence,
    this.grammageLabel,
  });
  final String skuId, skuName, skuCode;
  final double confidence;
  final String? grammageLabel;
}

// -----------------------------------------------------------------------
// Domain entities (mirrored from DB but dependency-free)
// -----------------------------------------------------------------------

class Beat {
  const Beat({
    required this.id,
    required this.code,
    required this.name,
    this.repName,
    required this.createdAt,
  });
  final String id, code, name;
  final String? repName;
  final int createdAt;
}

class Store {
  const Store({
    required this.id,
    required this.code,
    required this.name,
    required this.beatId,
    this.address,
    this.ownerName,
    this.phone,
    this.lat,
    this.lng,
    required this.sequence,
    required this.createdAt,
  });
  final String id, code, name, beatId;
  final String? address, ownerName, phone;
  final double? lat, lng;
  final int sequence, createdAt;
}

class Sku {
  const Sku({
    required this.id,
    required this.code,
    required this.name,
    this.brand,
    this.category,
    this.grammageValue,
    this.grammageUnit,
    this.variant,
    required this.mrpPaise,
    required this.caseSize,
    required this.isEnrolled,
    required this.isActive,
    required this.createdAt,
  });
  final String id, code, name;
  final String? brand, category, grammageUnit, variant;
  final double? grammageValue;
  final int mrpPaise, caseSize, createdAt;
  final bool isEnrolled, isActive;

  String get grammageLabel {
    if (grammageValue == null) return '';
    final v = grammageValue!;
    final disp = v == v.truncate() ? v.toInt().toString() : v.toString();
    return '$disp ${grammageUnit ?? ''}';
  }

  /// Price in rupees (display only — never compute in rupees).
  double get mrpRupees => mrpPaise / 100.0;
}

extension on double {
  double truncate() => floorToDouble();
}

class ShelfFact {
  const ShelfFact({
    required this.id,
    required this.visitId,
    required this.skuId,
    this.skuName,
    this.skuCode,
    this.grammageLabel,
    required this.detectedFacings,
    required this.targetFacings,
    required this.status,
    required this.computedAt,
  });
  final String id, visitId, skuId;
  final String? skuName, skuCode, grammageLabel;
  final int detectedFacings, targetFacings, computedAt;
  final ShelfStatus status;
}

class OrderLine {
  const OrderLine({
    required this.id,
    required this.visitId,
    required this.skuId,
    this.skuName,
    this.skuCode,
    this.grammageLabel,
    required this.mrpPaise,
    required this.caseSize,
    required this.suggestedQty,
    required this.finalQty,
    required this.unit,
    required this.valuePaise,
    required this.wasOverridden,
    required this.createdAt,
  });
  final String id, visitId, skuId;
  final String? skuName, skuCode, grammageLabel;
  final int mrpPaise, caseSize, suggestedQty, finalQty, valuePaise, createdAt;
  final String unit;
  final bool wasOverridden;

  double get valueRupees => valuePaise / 100.0;
}

/// Summary of one store's visit status within a beat — used on /beat screen.
class VisitSummary {
  const VisitSummary({
    required this.visitId,
    required this.storeId,
    required this.storeCode,
    required this.storeName,
    required this.status,
    required this.lineCount,
    required this.totalValuePaise,
    required this.stockoutCount,
    this.startedAt,
    this.confirmedAt,
  });
  final String visitId, storeId, storeCode, storeName;
  final VisitStatus status;
  final int lineCount, totalValuePaise, stockoutCount;
  final int? startedAt, confirmedAt;
}

/// Model load/latency record for the Diagnostics screen.
class ModelStat {
  const ModelStat({
    required this.kind,
    required this.label,
    required this.assetPath,
    required this.loadedOk,
    this.loadMs,
    this.meanLatencyMs,
    required this.runCount,
    this.lastError,
  });
  final ModelKind kind;
  final String label, assetPath;
  final bool loadedOk;
  final int? loadMs;
  final double? meanLatencyMs;
  final int runCount;
  final String? lastError;
}
