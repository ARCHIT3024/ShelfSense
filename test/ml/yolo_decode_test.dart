import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/domain/models/models.dart';
import 'package:shelfsense/ml/detector/yolo_decode.dart';

/// Builds a [1, 5, N] channels-first output with the given (cx, cy, w, h, s).
Float32List _channelsFirst(List<List<double>> rows) {
  final n = rows.length;
  final out = Float32List(5 * n);
  for (var a = 0; a < n; a++) {
    for (var c = 0; c < 5; c++) {
      out[c * n + a] = rows[a][c];
    }
  }
  return out;
}

void main() {
  group('Letterbox', () {
    test('landscape 1920x1080 into 640 pads top/bottom', () {
      final lb = Letterbox.fit(1920, 1080, 640);
      expect(lb.scale, closeTo(1 / 3, 1e-9));
      expect(lb.padX, 0);
      expect(lb.padY, closeTo((640 - 360) / 2, 1e-9));
    });
    test('portrait 1080x1920 into 640 pads left/right', () {
      final lb = Letterbox.fit(1080, 1920, 640);
      expect(lb.padY, 0);
      expect(lb.padX, closeTo((640 - 360) / 2, 1e-9));
    });
  });

  group('decodeYolo', () {
    final lb = Letterbox.fit(1920, 1080, 640); // scale 1/3, padY 140

    test('pixel coords undo the letterbox and normalise to the original', () {
      // A box centred on the letterboxed image, 320x180 px in input space.
      final out = _channelsFirst([
        [320, 320, 320, 180, 0.9],
      ]);
      final boxes = decodeYolo(out,
          channels: 5,
          anchors: 1,
          layout: YoloLayout.channelsFirst,
          box: lb,
          confThreshold: 0.35);
      expect(boxes, hasLength(1));
      final b = boxes.single;
      // x: (320-160-0)/(1/3)/1920 = 0.25 .. 0.75
      expect(b.x1, closeTo(0.25, 1e-6));
      expect(b.x2, closeTo(0.75, 1e-6));
      // y: (320-90-140)/(1/3)/1080 = 0.25 .. 0.75
      expect(b.y1, closeTo(0.25, 1e-6));
      expect(b.y2, closeTo(0.75, 1e-6));
      expect(b.score, closeTo(0.9, 1e-6));
    });

    test('normalised coords are auto-detected and scaled by input size', () {
      final out = _channelsFirst([
        [0.5, 0.5, 0.5, 0.28125, 0.8], // same box as above, /640
      ]);
      final boxes = decodeYolo(out,
          channels: 5,
          anchors: 1,
          layout: YoloLayout.channelsFirst,
          box: lb,
          confThreshold: 0.35);
      expect(boxes.single.x1, closeTo(0.25, 1e-6));
      expect(boxes.single.y2, closeTo(0.75, 1e-6));
    });

    test('anchors-first layout decodes identically', () {
      final rows = [
        [320.0, 320.0, 320.0, 180.0, 0.9],
        [100.0, 300.0, 50.0, 50.0, 0.1],
      ];
      final out = Float32List.fromList(rows.expand((r) => r).toList());
      final boxes = decodeYolo(out,
          channels: 5,
          anchors: 2,
          layout: YoloLayout.anchorsFirst,
          box: lb,
          confThreshold: 0.35);
      expect(boxes, hasLength(1)); // second is below threshold
      expect(boxes.single.x1, closeTo(0.25, 1e-6));
    });

    test('multi-class output uses the max class score', () {
      // channels = 4 + 2 classes
      final out = Float32List.fromList([
        320, 320, 320, 180, 0.2, 0.7, // [1, N=1, C=6] anchors-first
      ]);
      final boxes = decodeYolo(out,
          channels: 6,
          anchors: 1,
          layout: YoloLayout.anchorsFirst,
          box: lb,
          confThreshold: 0.35);
      expect(boxes.single.score, closeTo(0.7, 1e-6));
    });

    test('boxes are clamped into the image and degenerate ones dropped', () {
      final out = _channelsFirst([
        [0, 320, 100, 100, 0.9], // hangs off the left edge
        [320, 10, 100, 100, 0.9], // entirely inside the top padding
      ]);
      final boxes = decodeYolo(out,
          channels: 5,
          anchors: 2,
          layout: YoloLayout.channelsFirst,
          box: lb,
          confThreshold: 0.35);
      expect(boxes, hasLength(1));
      expect(boxes.single.x1, 0);
    });
  });

  group('nms', () {
    RawBox b(double x1, double y1, double x2, double y2, double s) =>
        RawBox(x1: x1, y1: y1, x2: x2, y2: y2, score: s);

    test('suppresses overlapping lower-scored boxes', () {
      final kept = nms([
        b(0, 0, 0.5, 0.5, 0.6),
        b(0.02, 0.02, 0.52, 0.52, 0.9),
        b(0.6, 0.6, 0.9, 0.9, 0.5),
      ], iouThreshold: 0.5, maxBoxes: 100);
      expect(kept.map((k) => k.score), [0.9, 0.5]);
    });

    test('respects maxBoxes', () {
      final kept = nms([
        for (var i = 0; i < 10; i++) b(i * 0.1, 0, i * 0.1 + 0.05, 0.1, 0.5),
      ], iouThreshold: 0.5, maxBoxes: 3);
      expect(kept, hasLength(3));
    });

    test('iou of identical boxes is 1, disjoint is 0', () {
      expect(iou(b(0, 0, 1, 1, 1), b(0, 0, 1, 1, 1)), closeTo(1, 1e-9));
      expect(iou(b(0, 0, 0.4, 0.4, 1), b(0.5, 0.5, 1, 1, 1)), 0);
    });
  });
}
