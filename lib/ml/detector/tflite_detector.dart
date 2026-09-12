/// T-13 — `DetectorService` on tflite_flutter.
///
/// Load order: GPU delegate → XNNPACK → plain CPU. On load it dumps every
/// input/output tensor (shape, type, quantisation) to the log and asserts
/// the contract in TRD §4.2 *before* any decode logic runs. Preprocessing
/// (decode + EXIF bake + letterbox + quantise) happens in an isolate; the
/// interpreter runs on its own isolate too, so the UI never stalls.
///
/// Detect on a captured still only — never on the preview stream.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../core/failures.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../domain/models/models.dart';
import '../common/thresholds.dart';
import 'detector_service.dart';
import 'yolo_decode.dart';

const _tag = 'TfliteDetector';

/// Runtime-tunable knobs (Diagnostics sliders write these — T-25).
class DetectorConfig {
  const DetectorConfig({
    this.confThreshold = kDetConfThreshold,
    this.nmsIou = kDetNmsIou,
    this.maxBoxes = kDetMaxBoxes,
  });
  final double confThreshold;
  final double nmsIou;
  final int maxBoxes;
}

/// What we learned about the model at load time — surfaced on /diagnostics.
class DetectorInfo {
  const DetectorInfo({
    required this.inputSize,
    required this.inputType,
    required this.outputShape,
    required this.outputType,
    required this.layout,
    required this.channels,
    required this.anchors,
    required this.delegate,
    required this.loadMs,
  });
  final int inputSize;
  final TensorType inputType;
  final List<int> outputShape;
  final TensorType outputType;
  final YoloLayout layout;
  final int channels, anchors;
  final String delegate;
  final int loadMs;

  @override
  String toString() =>
      'in ${inputSize}x$inputSize $inputType · out $outputShape $outputType '
      '($layout, $channels ch × $anchors anchors) · $delegate · load ${loadMs}ms';
}

class TfliteDetector implements DetectorService {
  TfliteDetector({
    this.assetPath,
    this.config = const DetectorConfig(),
  });

  /// Explicit model path, or `null` to take the first of [kCandidateAssets]
  /// that exists — so A can drop in whichever export succeeded first.
  final String? assetPath;

  static const kCandidateAssets = [
    'assets/models/detector_int8.tflite',
    'assets/models/detector_fp16.tflite',
    'assets/models/detector_fp32.tflite',
  ];
  String? loadedAsset;
  DetectorConfig config;

  Interpreter? _interpreter;
  IsolateInterpreter? _isolate;
  DetectorInfo? _info;
  Tensor? _inT, _outT;

  DetectorInfo? get info => _info;
  bool get isLoaded => _interpreter != null;

  /// Mean latency of the last few runs, for the Diagnostics card.
  final List<int> _latencies = [];
  int get meanLatencyMs => _latencies.isEmpty
      ? 0
      : _latencies.reduce((a, b) => a + b) ~/ _latencies.length;

  @override
  Future<Result<void, Failure>> load() async {
    if (_interpreter != null) return const Ok(null);
    final t0 = DateTime.now().millisecondsSinceEpoch;

    // Find the model bytes first so a missing file fails fast and quietly.
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
      AppLogger.w(_tag, 'No detector model bundled — manual boxes');
      return const Err(DetectorNotLoaded());
    }

    Interpreter? interp;
    var delegateName = 'cpu';
    for (final attempt in ['gpu', 'xnnpack', 'cpu']) {
      try {
        final opts = InterpreterOptions()..threads = 4;
        switch (attempt) {
          case 'gpu':
            opts.addDelegate(GpuDelegateV2());
          case 'xnnpack':
            opts.addDelegate(XNNPackDelegate());
        }
        interp = Interpreter.fromBuffer(bytes, options: opts);
        delegateName = attempt;
        break;
      } catch (e) {
        AppLogger.w(_tag, 'Delegate $attempt failed: $e');
      }
    }
    if (interp == null) {
      return const Err(DetectorNotLoaded());
    }
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
      if (ish.length != 4 || ish[0] != 1 || ish[3] != 3 || ish[1] != ish[2]) {
        throw StateError('input must be [1,S,S,3] NHWC, got $ish');
      }
      final osh = outT.shape;
      if (osh.length != 3 || osh[0] != 1) {
        throw StateError('output must be [1,C,N] or [1,N,C], got $osh');
      }
      // Channels are 4 + nc (small); anchors are thousands.
      final YoloLayout layout;
      final int channels, anchors;
      if (osh[1] <= 64 && osh[2] > osh[1]) {
        layout = YoloLayout.channelsFirst;
        channels = osh[1];
        anchors = osh[2];
      } else if (osh[2] <= 64 && osh[1] > osh[2]) {
        layout = YoloLayout.anchorsFirst;
        channels = osh[2];
        anchors = osh[1];
      } else {
        throw StateError('cannot tell channels from anchors in $osh');
      }
      if (channels < 5) throw StateError('need ≥5 channels (xywh+score)');

      _interpreter = interp;
      _inT = inT;
      _outT = outT;
      _isolate = await IsolateInterpreter.create(address: interp.address);
      _info = DetectorInfo(
        inputSize: ish[1],
        inputType: inT.type,
        outputShape: osh,
        outputType: outT.type,
        layout: layout,
        channels: channels,
        anchors: anchors,
        delegate: delegateName,
        loadMs: DateTime.now().millisecondsSinceEpoch - t0,
      );
      AppLogger.i(_tag, 'Loaded: $_info');
      return const Ok(null);
    } catch (e) {
      interp.close();
      AppLogger.e(_tag, 'Tensor contract check failed', e);
      return Err(DetectorInferenceFailed('Model contract mismatch: $e'));
    }
  }

  @override
  Future<Result<List<RawBox>, Failure>> detect(String imagePath) async {
    final info = _info;
    final iso = _isolate;
    final inT = _inT, outT = _outT;
    if (info == null || iso == null || inT == null || outT == null) {
      return const Err(DetectorNotLoaded());
    }
    final t0 = DateTime.now().millisecondsSinceEpoch;
    try {
      // 1. Preprocess off the UI thread.
      final pre = await compute(
        _preprocess,
        _PreJob(
          path: imagePath,
          size: info.inputSize,
          quantise: inT.type != TensorType.float32,
          signed: inT.type == TensorType.int8,
          scale: inT.params.scale,
          zeroPoint: inT.params.zeroPoint,
        ),
      );

      // 2. Inference on the interpreter isolate.
      final outLen = info.channels * info.anchors;
      final Object input;
      final Object output;
      if (inT.type == TensorType.float32) {
        input = pre.floats!.reshape([1, info.inputSize, info.inputSize, 3]);
      } else {
        input = pre.bytes!.reshape([1, info.inputSize, info.inputSize, 3]);
      }
      if (outT.type == TensorType.float32) {
        output = Float32List(outLen).reshape(info.outputShape);
      } else {
        output = (outT.type == TensorType.int8
                ? Int8List(outLen)
                : Uint8List(outLen))
            .reshape(info.outputShape);
      }
      await iso.run(input, output);

      // 3. Flatten + dequantise.
      final flat = Float32List(outLen);
      var i = 0;
      void walk(Object o) {
        if (o is List) {
          for (final e in o) {
            walk(e);
          }
        } else if (o is num) {
          flat[i++] = o.toDouble();
        }
      }
      walk(output);
      if (outT.type != TensorType.float32) {
        final s = outT.params.scale, z = outT.params.zeroPoint;
        for (var k = 0; k < outLen; k++) {
          flat[k] = (flat[k] - z) * s;
        }
      }

      // 4. Decode + NMS.
      final boxes = nms(
        decodeYolo(
          flat,
          channels: info.channels,
          anchors: info.anchors,
          layout: info.layout,
          box: pre.letterbox,
          confThreshold: config.confThreshold,
        ),
        iouThreshold: config.nmsIou,
        maxBoxes: config.maxBoxes,
      );

      final ms = DateTime.now().millisecondsSinceEpoch - t0;
      _latencies.add(ms);
      if (_latencies.length > 20) _latencies.removeAt(0);
      AppLogger.i(_tag, '${boxes.length} boxes in ${ms}ms (pre ${pre.ms}ms)');
      return Ok(boxes);
    } catch (e) {
      AppLogger.e(_tag, 'Inference failed', e);
      return Err(DetectorInferenceFailed(e.toString()));
    }
  }

  Future<void> close() async {
    await _isolate?.close();
    _interpreter?.close();
    _isolate = null;
    _interpreter = null;
    _info = null;
  }
}

// ---------------------------------------------------------------------------
// Preprocess (runs in a compute isolate)
// ---------------------------------------------------------------------------

class _PreJob {
  const _PreJob({
    required this.path,
    required this.size,
    required this.quantise,
    required this.signed,
    required this.scale,
    required this.zeroPoint,
  });
  final String path;
  final int size;
  final bool quantise, signed;
  final double scale;
  final int zeroPoint;
}

class _PreResult {
  const _PreResult({
    required this.letterbox,
    required this.ms,
    this.floats,
    this.bytes,
  });
  final Letterbox letterbox;
  final int ms;
  final Float32List? floats; // NHWC RGB 0..1
  final List<int>? bytes; // Int8List or Uint8List, quantised
}

Future<_PreResult> _preprocess(_PreJob job) async {
  final t0 = DateTime.now().millisecondsSinceEpoch;
  var image = img.decodeImage(await File(job.path).readAsBytes());
  if (image == null) throw StateError('Could not decode ${job.path}');
  image = img.bakeOrientation(image);

  final lb = Letterbox.fit(image.width, image.height, job.size);
  final resized = img.copyResize(
    image,
    width: (image.width * lb.scale).round(),
    height: (image.height * lb.scale).round(),
    interpolation: img.Interpolation.linear,
  );
  // Grey (114) canvas, image pasted at the pad offset.
  final canvas = img.Image(width: job.size, height: job.size, numChannels: 3)
    ..clear(img.ColorRgb8(114, 114, 114));
  img.compositeImage(canvas, resized,
      dstX: lb.padX.round(), dstY: lb.padY.round());

  final n = job.size * job.size * 3;
  if (!job.quantise) {
    final out = Float32List(n);
    var i = 0;
    for (final p in canvas) {
      out[i++] = p.r / 255.0;
      out[i++] = p.g / 255.0;
      out[i++] = p.b / 255.0;
    }
    return _PreResult(
        letterbox: lb,
        ms: DateTime.now().millisecondsSinceEpoch - t0,
        floats: out);
  }

  // q = round(x / scale) + zero_point, x in 0..1
  final inv = 1.0 / job.scale;
  final lo = job.signed ? -128 : 0, hi = job.signed ? 127 : 255;
  final out = job.signed ? Int8List(n) : Uint8List(n);
  var i = 0;
  int q(int v) => (((v / 255.0) * inv).round() + job.zeroPoint).clamp(lo, hi);
  for (final p in canvas) {
    out[i++] = q(p.r.toInt());
    out[i++] = q(p.g.toInt());
    out[i++] = q(p.b.toInt());
  }
  return _PreResult(
      letterbox: lb,
      ms: DateTime.now().millisecondsSinceEpoch - t0,
      bytes: out);
}
