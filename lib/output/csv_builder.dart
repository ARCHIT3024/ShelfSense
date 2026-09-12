/// On-device CSV generation — companion to xlsx_builder.dart (T-08/T-19).
/// Plain Dart, no dependency: CSV is simple enough not to need a package,
/// and this is one less licence to track.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/failures.dart';
import '../core/logger.dart';
import '../core/result.dart';
import '../domain/models/models.dart';

const _tag = 'CsvBuilder';

const _headers = [
  'SKU Code',
  'SKU Name',
  'Grammage',
  'MRP (Rs)',
  'Case Size',
  'Suggested Qty',
  'Final Qty',
  'Unit',
  'Value (Rs)',
  'Overridden',
];

String _csvField(Object? value) {
  final s = value?.toString() ?? '';
  if (s.contains(',') || s.contains('"') || s.contains('\n')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

String buildOrderCsvString(List<OrderLine> lines) {
  final buffer = StringBuffer()..writeln(_headers.map(_csvField).join(','));
  for (final line in lines) {
    buffer.writeln([
      line.skuCode ?? '',
      line.skuName ?? '',
      line.grammageLabel ?? '',
      (line.mrpPaise / 100.0).toStringAsFixed(2),
      line.caseSize,
      line.suggestedQty,
      line.finalQty,
      line.unit,
      line.valueRupees.toStringAsFixed(2),
      line.wasOverridden ? 'Y' : 'N',
    ].map(_csvField).join(','));
  }
  return buffer.toString();
}

/// Writes the order lines to a CSV file in app storage. Returns the path.
Future<Result<String, Failure>> buildOrderCsv({
  required String storeCode,
  required List<OrderLine> lines,
}) async {
  try {
    final csv = buildOrderCsvString(lines);
    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(dir.path, 'exports'));
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }
    final fileName =
        'order_${storeCode}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(p.join(exportsDir.path, fileName));
    await file.writeAsString(csv, flush: true);

    AppLogger.i(_tag, 'Wrote ${file.path} (${lines.length} lines)');
    return Ok(file.path);
  } catch (e) {
    AppLogger.e(_tag, 'CSV build failed', e);
    return Err(ExportFailed('CSV build failed: $e'));
  }
}
