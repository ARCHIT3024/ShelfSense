/// T-30 — `OcrService` on google_mlkit_text_recognition (bundled Latin model,
/// fully offline). Created lazily on first use; only ever called on a crop
/// the recogniser could not settle — never on the preview stream and never
/// on accepted or unmatched boxes (see capture_screen.dart).
library;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../core/failures.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import 'ocr_service.dart';

const _tag = 'MlKitOcr';

class MlKitOcrService implements OcrService {
  TextRecognizer? _recognizer;

  /// Mean latency of the last few runs, for the Diagnostics card.
  final List<int> _latencies = [];
  int get meanLatencyMs => _latencies.isEmpty
      ? 0
      : _latencies.reduce((a, b) => a + b) ~/ _latencies.length;
  int get runCount => _latencies.length;

  TextRecognizer get _r =>
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<Result<String, Failure>> recognizeText(String cropImagePath) async {
    final t0 = DateTime.now().millisecondsSinceEpoch;
    try {
      final result = await _r.processImage(InputImage.fromFilePath(cropImagePath));
      final ms = DateTime.now().millisecondsSinceEpoch - t0;
      _latencies.add(ms);
      if (_latencies.length > 20) _latencies.removeAt(0);
      final text = result.text.replaceAll('\n', ' ').trim();
      AppLogger.i(_tag, '${text.length} chars in ${ms}ms: "${_short(text)}"');
      return Ok(text);
    } catch (e) {
      AppLogger.e(_tag, 'OCR failed', e);
      return Err(OcrFailed(e.toString()));
    }
  }

  Future<void> close() async {
    await _recognizer?.close();
    _recognizer = null;
  }

  static String _short(String s) => s.length <= 60 ? s : '${s.substring(0, 57)}…';
}
