/// T-13 — `DetectorService` on tflite_flutter.
///
/// Load order: GPU delegate → XNNPACK → plain CPU. On load it dumps every
/// input/output tensor (shape, type, quantisation) to the log and asserts
/// the contract in TRD §4.2 *before* any decode logic runs. Preprocessing
/// (decode + EXIF bake + letterbox + quantise) happens in a compute isolate.
/// Inference itself runs on the main isolate: tflite_flutter's
/// IsolateInterpreter re-allocates tensors on every call (Interpreter
/// .fromAddress → allocateTensors), which breaks the XNNPACK memory plan
/// ("Input tensor N lacks data") and hangs the caller. A YOLO11n INT8
/// invoke is tens of ms on this SoC, behind the shutter overlay anyway.
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
    required this.inputNchw,
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
  final bool inputNchw;
  final TensorType inputType;
  final List<int> outputShape;
  final TensorType outputType;
  final YoloLayout layout;
  final int channels, anchors;
  final String delegate;
  final int loadMs;

  @override
  String toString() =>
      'in ${inputSize}x$inputSize ${inputNchw ? 'NCHW' : 'NHWC'} $inputType · out $outputShape $outputType '
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
  DetectorInfo? _info;
  Tensor? _inT, _outT;

  DetectorInfo? get info => _info;
  @override
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
    for (final path in [?assetPath, ...kCandidateAssets]) {
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
    // GPU first; otherwise plain options — the TFLite runtime applies its
    // own XNNPACK delegate for CPU by default (adding it explicitly on top
    // double-applies it).
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
    if (interp == null) {
      return const Err(DetectorNotLoaded());
    }
    // The GPU delegate can "succeed" at creation yet be dropped at prepare
    // time (per-channel INT8 is unsupported); the tflite runtime logs that
    // itself. Label honestly: INT8 models run on XNNPACK/CPU.
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
      // TF-style export gives NHWC [1,S,S,3]; the LiteRT/ai-edge-torch path
      // keeps PyTorch's NCHW [1,3,S,S]. Accept both, remember which.
      final bool nchw;
      if (ish.length == 4 && ish[0] == 1 && ish[3] == 3 && ish[1] == ish[2]) {
        nchw = false;
      } else if (ish.length == 4 && ish[0] == 1 && ish[1] == 3 && ish[2] == ish[3]) {
        nchw = true;
      } else {
        throw StateError('input must be [1,S,S,3] or [1,3,S,S], got $ish');
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
      _info = DetectorInfo(
        inputSize: nchw ? ish[2] : ish[1],
        inputNchw: nchw,
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
    final interp = _interpreter;
    final inT = _inT, outT = _outT;
    if (info == null || interp == null || inT == null || outT == null) {
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
          nchw: info.inputNchw,
          quantise: inT.type != TensorType.float32,
          signed: inT.type == TensorType.int8,
          scale: inT.params.scale,
          zeroPoint: inT.params.zeroPoint,
        ),
      );

      // 2. Inference. Raw bytes in and out —
      //    tflite_flutter memcpys Uint8List/ByteBuffer, but converts nested
      //    Dart lists element by element (tens of seconds for 640×640×3).
      final outLen = info.channels * info.anchors;
      final Uint8List inputBytes = inT.type == TensorType.float32
          ? pre.floats!.buffer.asUint8List()
          : (pre.bytes as TypedData).buffer.asUint8List();
      final outBytes = outT.type == TensorType.float32 ? outLen * 4 : outLen;
      final outBuf = Uint8List(outBytes).buffer;
      final tInf = DateTime.now().millisecondsSinceEpoch;
      interp.run(inputBytes, outBuf);
      final infMs = DateTime.now().millisecondsSinceEpoch - tInf;

      // 3. View + dequantise.
      final Float32List flat;
      switch (outT.type) {
        case TensorType.float32:
          flat = outBuf.asFloat32List();
        case TensorType.int8:
          final s = outT.params.scale, z = outT.params.zeroPoint;
          final q = outBuf.asInt8List();
          flat = Float32List(outLen);
          for (var k = 0; k < outLen; k++) {
            flat[k] = (q[k] - z) * s;
          }
        default:
          final s = outT.params.scale, z = outT.params.zeroPoint;
          final q = outBuf.asUint8List();
          flat = Float32List(outLen);
          for (var k = 0; k < outLen; k++) {
            flat[k] = (q[k] - z) * s;
          }
      }

      // 4. Decode + NMS.
      final boxes = mergeStackedFragments(nms(
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
      ));

      final ms = DateTime.now().millisecondsSinceEpoch - t0;
      _latencies.add(ms);
      if (_latencies.length > 20) _latencies.removeAt(0);
      AppLogger.i(_tag,
          '${boxes.length} boxes in ${ms}ms (pre ${pre.ms} · infer $infMs · '
          'post ${ms - pre.ms - infMs})');
      return Ok(boxes);
    } catch (e) {
      AppLogger.e(_tag, 'Inference failed', e);
      return Err(DetectorInferenceFailed(e.toString()));
    }
  }

  Future<void> close() async {
    _interpreter?.close();
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
    required this.nchw,
    required this.quantise,
    required this.signed,
    required this.scale,
    required this.zeroPoint,
  });
  final String path;
  final int size;
  final bool nchw, quantise, signed;
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
  final plane = job.size * job.size;
  // NHWC interleaves rgb per pixel; NCHW writes three planes.
  int idx(int px, int ch) => job.nchw ? ch * plane + px : px * 3 + ch;
  if (!job.quantise) {
    final out = Float32List(n);
    var px = 0;
    for (final p in canvas) {
      out[idx(px, 0)] = p.r / 255.0;
      out[idx(px, 1)] = p.g / 255.0;
      out[idx(px, 2)] = p.b / 255.0;
      px++;
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
  var px = 0;
  int q(int v) => (((v / 255.0) * inv).round() + job.zeroPoint).clamp(lo, hi);
  for (final p in canvas) {
    out[idx(px, 0)] = q(p.r.toInt());
    out[idx(px, 1)] = q(p.g.toInt());
    out[idx(px, 2)] = q(p.b.toInt());
    px++;
  }
  return _PreResult(
      letterbox: lb,
      ms: DateTime.now().millisecondsSinceEpoch - t0,
      bytes: out);
}
