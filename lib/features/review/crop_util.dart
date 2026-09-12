import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Writes the crop of a normalised box out of [srcPath] as a JPEG and returns
/// the new file's path. Used to hand a pack to `/enrol` as its first shot.
///
/// Decoding a 1920 px JPEG takes a few hundred ms, so it runs in an isolate.
Future<String> writeBoxCrop({
  required String srcPath,
  required double x1,
  required double y1,
  required double x2,
  required double y2,
  required String outName,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final outDir = Directory(p.join(dir.path, 'crops'));
  await outDir.create(recursive: true);
  final outPath = p.join(outDir.path, '$outName.jpg');
  await compute(_cropIsolate, _CropJob(srcPath, outPath, x1, y1, x2, y2));
  return outPath;
}

class _CropJob {
  const _CropJob(this.src, this.out, this.x1, this.y1, this.x2, this.y2);
  final String src, out;
  final double x1, y1, x2, y2;
}

Future<void> _cropIsolate(_CropJob job) async {
  final bytes = await File(job.src).readAsBytes();
  var image = img.decodeImage(bytes);
  if (image == null) throw StateError('Could not decode ${job.src}');
  // Flutter's Image.file applies EXIF rotation, and the boxes were drawn on
  // that rotated view — bake the orientation in so the crop lines up.
  image = img.bakeOrientation(image);
  final x = (job.x1 * image.width).round().clamp(0, image.width - 1);
  final y = (job.y1 * image.height).round().clamp(0, image.height - 1);
  final w = ((job.x2 - job.x1) * image.width).round().clamp(1, image.width - x);
  final h =
      ((job.y2 - job.y1) * image.height).round().clamp(1, image.height - y);
  final crop = img.copyCrop(image, x: x, y: y, width: w, height: h);
  await File(job.out).writeAsBytes(img.encodeJpg(crop, quality: 90));
}
