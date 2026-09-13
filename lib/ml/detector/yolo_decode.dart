/// Pure decode + NMS for single-class YOLO (Ultralytics TFLite export).
/// No Flutter or TFLite imports so it is unit-testable on the desktop.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/models/models.dart';

/// How the model's output tensor is laid out. Ultralytics exports
/// `[1, 4+nc, N]` (channels first); some converters transpose to `[1, N, 4+nc]`.
enum YoloLayout { channelsFirst, anchorsFirst }

/// Letterbox geometry: original → padded square input.
class Letterbox {
  const Letterbox({
    required this.scale,
    required this.padX,
    required this.padY,
    required this.srcW,
    required this.srcH,
    required this.dstSize,
  });
  final double scale; // src px * scale = dst px
  final double padX, padY; // dst px
  final int srcW, srcH, dstSize;

  static Letterbox fit(int srcW, int srcH, int dstSize) {
    final scale = math.min(dstSize / srcW, dstSize / srcH);
    final newW = srcW * scale, newH = srcH * scale;
    return Letterbox(
      scale: scale,
      padX: (dstSize - newW) / 2,
      padY: (dstSize - newH) / 2,
      srcW: srcW,
      srcH: srcH,
      dstSize: dstSize,
    );
  }
}

/// Decodes a flat float output into boxes normalised to the *original* image.
///
/// [out] is the dequantised output tensor, [channels] = 4 + numClasses,
/// [anchors] = N. Coordinates are `cx, cy, w, h` either in input pixels or
/// normalised 0–1 — detected per call by [coordsNormalised]. With more than
/// one class the max class score is used (class-agnostic, TRD §4.2).
List<RawBox> decodeYolo(
  Float32List out, {
  required int channels,
  required int anchors,
  required YoloLayout layout,
  required Letterbox box,
  required double confThreshold,
  bool? coordsNormalised,
}) {
  double at(int c, int a) => layout == YoloLayout.channelsFirst
      ? out[c * anchors + a]
      : out[a * channels + c];

  final normalised = coordsNormalised ?? _looksNormalised(at, anchors);
  final toPx = normalised ? box.dstSize.toDouble() : 1.0;
  final result = <RawBox>[];

  for (var a = 0; a < anchors; a++) {
    var score = at(4, a);
    for (var c = 5; c < channels; c++) {
      final s = at(c, a);
      if (s > score) score = s;
    }
    if (score < confThreshold) continue;

    final cx = at(0, a) * toPx, cy = at(1, a) * toPx;
    final w = at(2, a) * toPx, h = at(3, a) * toPx;
    // Letterbox px → original px → normalised.
    final x1 = ((cx - w / 2) - box.padX) / box.scale / box.srcW;
    final y1 = ((cy - h / 2) - box.padY) / box.scale / box.srcH;
    final x2 = ((cx + w / 2) - box.padX) / box.scale / box.srcW;
    final y2 = ((cy + h / 2) - box.padY) / box.scale / box.srcH;
    final cx1 = x1.clamp(0.0, 1.0), cy1 = y1.clamp(0.0, 1.0);
    final cx2 = x2.clamp(0.0, 1.0), cy2 = y2.clamp(0.0, 1.0);
    if (cx2 - cx1 <= 0 || cy2 - cy1 <= 0) continue;
    result.add(RawBox(x1: cx1, y1: cy1, x2: cx2, y2: cy2, score: score));
  }
  return result;
}

/// Ultralytics' TF exports emit normalised xywh; the ONNX path emits pixels.
/// If nothing exceeds 1.5 across a sample of anchors, treat as normalised.
bool _looksNormalised(double Function(int, int) at, int anchors) {
  final step = math.max(1, anchors ~/ 200);
  for (var a = 0; a < anchors; a += step) {
    for (var c = 0; c < 4; c++) {
      if (at(c, a) > 1.5) return false;
    }
  }
  return true;
}

double iou(RawBox a, RawBox b) {
  final ix1 = math.max(a.x1, b.x1), iy1 = math.max(a.y1, b.y1);
  final ix2 = math.min(a.x2, b.x2), iy2 = math.min(a.y2, b.y2);
  final iw = math.max(0.0, ix2 - ix1), ih = math.max(0.0, iy2 - iy1);
  final inter = iw * ih;
  final union = a.area + b.area - inter;
  return union <= 0 ? 0 : inter / union;
}

/// Greedy class-agnostic NMS, highest score first.
List<RawBox> nms(List<RawBox> boxes,
    {required double iouThreshold, required int maxBoxes}) {
  final sorted = [...boxes]..sort((a, b) => b.score.compareTo(a.score));
  final kept = <RawBox>[];
  for (final b in sorted) {
    if (kept.length >= maxBoxes) break;
    var suppressed = false;
    for (final k in kept) {
      if (iou(b, k) > iouThreshold) {
        suppressed = true;
        break;
      }
    }
    if (!suppressed) kept.add(b);
  }
  return kept;
}

/// Merges boxes that are vertical fragments of one tall product.
///
/// SKU-110K teaches the detector roughly square pack fronts, so a tall can
/// or bottle often comes back as two stacked boxes (logo band + lower
/// band) that NMS keeps because they barely overlap. Two boxes whose
/// horizontal extents overlap by ≥ [minXOverlap] of the narrower one and
/// whose vertical gap is at most [maxGapFrac] of the shorter one's height
/// are unioned into a single box carrying the higher score.
List<RawBox> mergeStackedFragments(
  List<RawBox> boxes, {
  double minXOverlap = 0.7,
  double maxGapFrac = 0.35,
}) {
  if (boxes.length < 2) return boxes;
  final out = <RawBox>[...boxes]..sort((a, b) => a.y1.compareTo(b.y1));
  var merged = true;
  while (merged) {
    merged = false;
    for (var i = 0; i < out.length && !merged; i++) {
      for (var j = i + 1; j < out.length; j++) {
        final a = out[i], b = out[j];
        final xo = math.min(a.x2, b.x2) - math.max(a.x1, b.x1);
        final narrower = math.min(a.width, b.width);
        if (narrower <= 0 || xo / narrower < minXOverlap) continue;
        final gap = math.max(a.y1, b.y1) - math.min(a.y2, b.y2); // <0 = overlap
        final shorter = math.min(a.height, b.height);
        if (gap > maxGapFrac * shorter) continue;
        out[i] = RawBox(
          x1: math.min(a.x1, b.x1),
          y1: math.min(a.y1, b.y1),
          x2: math.max(a.x2, b.x2),
          y2: math.max(a.y2, b.y2),
          score: math.max(a.score, b.score),
        );
        out.removeAt(j);
        merged = true;
        break;
      }
    }
  }
  return out;
}
