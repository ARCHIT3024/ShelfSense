/// T-20 — `EmbedderService` on tflite_flutter.
///
/// Same shape as `lib/ml/detector/tflite_detector.dart`, with the same three
/// hard-won rules: dump and assert the tensor contract on load; hand the
/// interpreter raw `Uint8List`/`ByteBuffer` (nested Dart lists take tens of
/// seconds to convert); and run inference on the MAIN isolate —
/// `IsolateInterpreter` re-runs `allocateTensors` per call, which breaks the
/// delegate memory plan and hangs the caller. A 224×224 MobileNetV3 forward
/// pass is single-digit ms here.
///
/// Preprocessing (decode, EXIF bake, crop, resize, ImageNet normalise) runs
/// in a compute isolate; a whole still is decoded once for all its boxes.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../core/failures.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../domain/models/models.dart';
import 'embedder_service.dart';

const _tag = 'TfliteEmbedder';

// ImageNet statistics (TRD §4.2).
const _kMean = [0.485, 0.456, 0.406];
const _kStd = [0.229, 0.224, 0.225];

/// What we learned about the model at load time — surfaced on /diagnostics.
class EmbedderInfo {
  const EmbedderInfo({
    required this.inputSize,
    required this.inputNchw,
    required this.inputType,
    required this.outputType,
    required this.dims,
    required this.delegate,
    required this.loadMs,
  });
  final int inputSize;
  final bool inputNchw;
  final TensorType inputType;
  final TensorType outputType;
  final int dims;
  final String delegate;
  final int loadMs;

  @override
  String toString() =>
      'in ${inputSize}x$inputSize ${inputNchw ? 'NCHW' : 'NHWC'} $inputType · '
      'out [1, $dims] $outputType · $delegate · load ${loadMs}ms';
}

class TfliteEmbedder extends EmbedderService {
  TfliteEmbedder({this.assetPath});

  /// Explicit model path, or `null` to take the first of [kCandidateAssets]
  /// that exists — so A can drop in whichever export succeeded first.
  final String? assetPath;

  static const kCandidateAssets = [
    'assets/models/embedder_int8.tflite',
    'assets/models/embedder_fp16.tflite',
    'assets/models/embedder_fp32.tflite',
  ];
  String? loadedAsset;

  Interpreter? _interpreter;
  EmbedderInfo? _info;
  Tensor? _inT, _outT;

  EmbedderInfo? get info => _info;

  @override
  bool get isLoaded => _interpreter != null;

  /// Mean latency per crop of the last few runs, for the Diagnostics card.
  final List<int> _latencies = [];
  int get meanLatencyMs => _latencies.isEmpty
      ? 0
      : _latencies.reduce((a, b) => a + b) ~/ _latencies.length;

  @override
  Future<Result<void, Failure>> load() async {
    if (_interpreter != null) return const Ok(null);
    final t0 = DateTime.now().millisecondsSinceEpoch;

    Uint8List? bytes;
    for (final path in [if (assetPath != null) assetPath!, ...kCandidateAssets]) {
      try {
        bytes = (await rootBundle.load(path)).buffer.asUint8List();
        loadedAsset = path;
        break;
      } catch (_) {
        // not bundled — try the next candidate
      }
    }
    if (bytes == null) {
      AppLogger.w(_tag, 'No embedder model bundled — boxes stay unmatched');
      return const Err(EmbedderNotLoaded());
    }

    Interpreter? interp;
    var delegateName = 'cpu';
    for (final attempt in ['gpu', 'cpu']) {
      try {
        final opts = InterpreterOptions()..threads = 4;
        if (attempt == 'gpu') opts.addDelegate(GpuDelegateV2());
        interp = Interpreter.fromBuffer(bytes, options: opts);
        delegateName = attempt;
        break;
      } catch (e) {
        AppLogger.w(_tag, 'Delegate $attempt failed: $e');
      }
    }
    if (interp == null) return const Err(EmbedderNotLoaded());
    if (delegateName == 'cpu') delegateName = 'cpu/xnnpack';
    AppLogger.i(_tag, 'Using $loadedAsset');

    // ---- Dump + assert the tensor contract before anything else --------
    final inputs = interp.getInputTensors();
    final outputs = interp.getOutputTensors();
    for (final t in inputs) {
      AppLogger.i(_tag, 'INPUT  ${t.name} ${t.shape} ${t.type} q=${t.params}');
    }
    for (final t in outputs) {
      AppLogger.i(_tag, 'OUTPUT ${t.name} ${t.shape} ${t.type} q=${t.params}');
    }
    try {
      final inT = inputs.single;
      final outT = outputs.single;
      final ish = inT.shape;
      final bool nchw;
      if (ish.length == 4 && ish[0] == 1 && ish[3] == 3 && ish[1] == ish[2]) {
        nchw = false;
      } else if (ish.length == 4 && ish[0] == 1 && ish[1] == 3 && ish[2] == ish[3]) {
        nchw = true;
      } else {
        throw StateError('input must be [1,S,S,3] or [1,3,S,S], got $ish');
      }
      final osh = outT.shape;
      if (osh.length != 2 || osh[0] != 1 || osh[1] < 8) {
        throw StateError('output must be [1,D], got $osh');
      }
      if (osh[1] != 128) {
        AppLogger.w(_tag, 'Embedding is ${osh[1]}-d, not 128 — fine, but '
            'sku_embeddings blobs will not be 512 bytes');
      }

      _interpreter = interp;
      _inT = inT;
      _outT = outT;
      _info = EmbedderInfo(
        inputSize: nchw ? ish[2] : ish[1],
        inputNchw: nchw,
        inputType: inT.type,
        outputType: outT.type,
        dims: osh[1],
        delegate: delegateName,
        loadMs: DateTime.now().millisecondsSinceEpoch - t0,
      );
      AppLogger.i(_tag, 'Loaded: $_info');
      return const Ok(null);
    } catch (e) {
      interp.close();
      AppLogger.e(_tag, 'Tensor contract check failed', e);
      return Err(EmbedderInferenceFailed('Model contract mismatch: $e'));
    }
  }

  @override
  Future<Result<List<double>, Failure>> embed(String cropImagePath) async {
    final r = await embedBoxes(
        cropImagePath, const [RawBox(x1: 0, y1: 0, x2: 1, y2: 1, score: 1)]);
    return switch (r) {
      Ok(:final value) => value.first == null
          ? const Err(EmbedderInferenceFailed('preprocess produced nothing'))
          : Ok(value.first!),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<List<List<double>?>, Failure>> embedBoxes(
      String imagePath, List<RawBox> boxes) async {
    final info = _info;
    final interp = _interpreter;
    final inT = _inT, outT = _outT;
    if (info == null || interp == null || inT == null || outT == null) {
      return const Err(EmbedderNotLoaded());
    }
    if (boxes.isEmpty) return const Ok([]);
    final t0 = DateTime.now().millisecondsSinceEpoch;
    try {
      // 1. Decode the still once, crop + resize + normalise every box.
      final pre = await compute(
        _preprocess,
        _PreJob(
          path: imagePath,
          size: info.inputSize,
          nchw: info.inputNchw,
          quantise: inT.type != TensorType.float32,
          signed: inT.type == TensorType.int8,
          scale: inT.params.scale,
          zeroPoint: inT.params.zeroPoint,
          boxes: [for (final b in boxes) [b.x1, b.y1, b.x2, b.y2]],
        ),
      );

      // 2. One forward pass per crop on the main isolate, raw bytes I/O.
      final d = info.dims;
      final outBytes = outT.type == TensorType.float32 ? d * 4 : d;
      final results = <List<double>?>[];
      var inferMs = 0;
      for (final input in pre.inputs) {
        final outBuf = Uint8List(outBytes).buffer;
        final tInf = DateTime.now().millisecondsSinceEpoch;
        interp.run(input, outBuf);
        inferMs += DateTime.now().millisecondsSinceEpoch - tInf;
        results.add(_readVector(outBuf, outT, d));
      }

      final ms = DateTime.now().millisecondsSinceEpoch - t0;
      if (results.isNotEmpty) {
        _latencies.add(inferMs ~/ results.length);
        if (_latencies.length > 20) _latencies.removeAt(0);
      }
      AppLogger.i(_tag,
          '${results.length} crops in ${ms}ms (pre ${pre.ms} · infer $inferMs)');
      return Ok(results);
    } catch (e) {
      AppLogger.e(_tag, 'Inference failed', e);
      return Err(EmbedderInferenceFailed(e.toString()));
    }
  }

  /// Dequantise if needed, then L2-normalise defensively so cosine is a
  /// plain dot product regardless of how the model was exported.
  List<double> _readVector(ByteBuffer buf, Tensor outT, int d) {
    final v = Float32List(d);
    switch (outT.type) {
      case TensorType.float32:
        v.setAll(0, buf.asFloat32List());
      case TensorType.int8:
        final s = outT.params.scale, z = outT.params.zeroPoint;
        final q = buf.asInt8List();
        for (var k = 0; k < d; k++) {
          v[k] = (q[k] - z) * s;
        }
      default:
        final s = outT.params.scale, z = outT.params.zeroPoint;
        final q = buf.asUint8List();
        for (var k = 0; k < d; k++) {
          v[k] = (q[k] - z) * s;
        }
    }
    return l2Normalise(v);
  }

  Future<void> close() async {
    _interpreter?.close();
    _interpreter = null;
    _info = null;
  }
}

/// Returns [v] scaled to unit length (a zero vector is returned unchanged).
List<double> l2Normalise(List<double> v) {
  var sum = 0.0;
  for (final x in v) {
    sum += x * x;
  }
  if (sum <= 0) return List<double>.from(v);
  final inv = 1 / math.sqrt(sum);
  return [for (final x in v) x * inv];
}

// ---------------------------------------------------------------------------
// Preprocess (runs in a compute isolate)
// ---------------------------------------------------------------------------

class _PreJob {
  const _PreJob({
    required this.path,
    required this.size,
    required this.nchw,
    required this.quantise,
    required this.signed,
    required this.scale,
    required this.zeroPoint,
    required this.boxes,
  });
  final String path;
  final int size;
  final bool nchw, quantise, signed;
  final double scale;
  final int zeroPoint;
  final List<List<double>> boxes; // normalised x1,y1,x2,y2
}

class _PreResult {
  const _PreResult({required this.inputs, required this.ms});
  final List<Uint8List> inputs; // one raw input buffer per box
  final int ms;
}

Future<_PreResult> _preprocess(_PreJob job) async {
  final t0 = DateTime.now().millisecondsSinceEpoch;
  var image = img.decodeImage(await File(job.path).readAsBytes());
  if (image == null) throw StateError('Could not decode ${job.path}');
  image = img.bakeOrientation(image);

  final n = job.size * job.size * 3;
  final plane = job.size * job.size;
  int idx(int px, int ch) => job.nchw ? ch * plane + px : px * 3 + ch;
  final inv = 1.0 / job.scale;
  final lo = job.signed ? -128 : 0, hi = job.signed ? 127 : 255;

  final inputs = <Uint8List>[];
  for (final b in job.boxes) {
    final x = (b[0] * image.width).round().clamp(0, image.width - 1);
    final y = (b[1] * image.height).round().clamp(0, image.height - 1);
    final w = ((b[2] - b[0]) * image.width).round().clamp(1, image.width - x);
    final h = ((b[3] - b[1]) * image.height).round().clamp(1, image.height - y);
    // A whole-image "box" (embed of an already-cropped file) skips the crop.
    final crop = (x == 0 && y == 0 && w == image.width && h == image.height)
        ? image
        : img.copyCrop(image, x: x, y: y, width: w, height: h);
    final resized = img.copyResize(crop,
        width: job.size, height: job.size, interpolation: img.Interpolation.linear);

    if (!job.quantise) {
      final out = Float32List(n);
      var px = 0;
      for (final p in resized) {
        out[idx(px, 0)] = (p.r / 255.0 - _kMean[0]) / _kStd[0];
        out[idx(px, 1)] = (p.g / 255.0 - _kMean[1]) / _kStd[1];
        out[idx(px, 2)] = (p.b / 255.0 - _kMean[2]) / _kStd[2];
        px++;
      }
      inputs.add(out.buffer.asUint8List());
    } else {
      // q = round(x / scale) + zero_point, x = normalised value
      final out = job.signed ? Int8List(n) : Uint8List(n);
      var px = 0;
      int q(double v) => ((v * inv).round() + job.zeroPoint).clamp(lo, hi);
      for (final p in resized) {
        out[idx(px, 0)] = q((p.r / 255.0 - _kMean[0]) / _kStd[0]);
        out[idx(px, 1)] = q((p.g / 255.0 - _kMean[1]) / _kStd[1]);
        out[idx(px, 2)] = q((p.b / 255.0 - _kMean[2]) / _kStd[2]);
        px++;
      }
      inputs.add((out as TypedData).buffer.asUint8List());
    }
  }
  return _PreResult(
      inputs: inputs, ms: DateTime.now().millisecondsSinceEpoch - t0);
}
