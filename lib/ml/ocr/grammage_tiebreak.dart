/// F-22 — resolve a low-confidence match between same-brand size variants
/// by reading the pack size off the crop.
///
/// Fires only when the recogniser's top candidates are the *same product in
/// different sizes* (e.g. Pepsi 450 / 550 / 1000 ml): the embedding cannot
/// separate those, but the printed grammage can. Never guesses — when the
/// text supports zero or several candidates the low-confidence match stays.
library;

import '../../core/logger.dart';
import '../../core/result.dart';
import '../../data/db/database.dart';
import '../../domain/models/models.dart';
import '../common/image_crop.dart';
import 'grammage_parser.dart';
import 'ocr_service.dart';

const _tag = 'OcrTiebreak';

/// Cap so a rack full of ambiguous boxes cannot stall the shutter.
const kOcrMaxBoxesPerPhoto = 10;

/// True when at least two of [candidates] are size variants of one product:
/// same brand (or same first word of the name) but a different grammage.
bool isSizeVariantGroup(List<SkuCandidate> candidates, Map<String, SkusData> skus) {
  final byKey = <String, Set<String>>{};
  for (final c in candidates) {
    final s = skus[c.skuId];
    if (s == null) continue;
    final g = Grammage.fromSku(s.grammageValue, s.grammageUnit);
    if (g == null) continue;
    byKey.putIfAbsent(_brandKey(s), () => <String>{}).add(g.toString());
  }
  return byKey.values.any((sizes) => sizes.length >= 2);
}

String _brandKey(SkusData s) {
  final b = s.brand?.trim().toLowerCase();
  if (b != null && b.isNotEmpty) return b;
  return s.name.trim().toLowerCase().split(RegExp(r'\s+')).first;
}

/// Runs OCR on the box and returns the candidate the printed size supports,
/// or null. [candidates] should be the top-3 for the box.
Future<SkuCandidate?> resolveByGrammage({
  required OcrService ocr,
  required String imagePath,
  required RawBox box,
  required List<SkuCandidate> candidates,
  required Map<String, SkusData> skus,
  required String cropName,
}) async {
  final t0 = DateTime.now().millisecondsSinceEpoch;
  final String cropPath;
  try {
    cropPath = await writeBoxCrop(
      srcPath: imagePath,
      x1: box.x1,
      y1: box.y1,
      x2: box.x2,
      y2: box.y2,
      outName: cropName,
    );
  } catch (e) {
    AppLogger.w(_tag, 'crop failed: $e');
    return null;
  }
  final text = switch (await ocr.recognizeText(cropPath)) {
    Ok(:final value) => value,
    Err() => '',
  };
  if (text.isEmpty) return null;
  final read = parseGrammages(text);
  if (read.isEmpty) return null;

  final sizes = [
    for (final c in candidates)
      () {
        final s = skus[c.skuId];
        return s == null ? null : Grammage.fromSku(s.grammageValue, s.grammageUnit);
      }(),
  ];
  final idx = pickByGrammage(read, sizes);
  final ms = DateTime.now().millisecondsSinceEpoch - t0;
  if (idx == null) {
    AppLogger.i(_tag, 'read $read — no single candidate matches (${ms}ms)');
    return null;
  }
  AppLogger.i(_tag,
      'read $read → ${candidates[idx].skuCode} (${sizes[idx]}) in ${ms}ms');
  return candidates[idx];
}
