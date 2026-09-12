/// On-device CSV generation — T-09.
///
/// Companion to xlsx_builder.dart. Plain Dart, zero extra packages —
/// CSV encoding is simple enough not to need a dependency, and this keeps
/// the licence list short.
///
/// RFC 4180 compliance:
///   - CRLF (\r\n) line endings
///   - Fields containing comma, double-quote, or newline are double-quoted
///   - Double-quotes inside fields are escaped as ""
///   - UTF-8 BOM prepended so Excel auto-detects encoding on Windows
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/failures.dart';
import '../core/logger.dart';
import '../core/result.dart';
import '../domain/models/models.dart';

const _tag = 'CsvBuilder';

/// UTF-8 BOM — makes Excel on Windows auto-detect encoding without a wizard.
const _kBom = '\uFEFF';

const _kHeaders = [
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

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Returns the CSV as a UTF-8 [Uint8List] (with BOM) without touching disk.
///
/// Use this with [share_plus] or in unit tests.
/// Returns [ExportFailed] when [lines] is empty.
Result<Uint8List, Failure> buildOrderCsvBytes({
  required List<OrderLine> lines,
}) {
  if (lines.isEmpty) {
    return Err(const ExportFailed('Cannot export: order has no lines.'));
  }
  try {
    final csv = buildOrderCsvString(lines);
    return Ok(utf8.encode(csv) as Uint8List);
  } catch (e, st) {
    AppLogger.e(_tag, 'CSV bytes build failed', e);
    return Err(ExportFailed('CSV build failed: $e\n$st'));
  }
}

/// Writes the CSV to `<documents>/exports/order_<storeCode>_<epoch>.csv`.
/// Returns the absolute path on success, or [ExportFailed] on error.
/// Never throws across the service boundary.
Future<Result<String, Failure>> buildOrderCsv({
  required String storeCode,
  required List<OrderLine> lines,
}) async {
  if (lines.isEmpty) {
    return Err(const ExportFailed('Cannot export: order has no lines.'));
  }
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
    // Write UTF-8; BOM is already the first char in buildOrderCsvString.
    await file.writeAsString(csv, encoding: utf8, flush: true);
    AppLogger.i(_tag, 'Wrote ${file.path} (${lines.length} lines)');
    return Ok(file.path);
  } catch (e, st) {
    AppLogger.e(_tag, 'CSV build failed', e);
    return Err(ExportFailed('CSV build failed: $e\n$st'));
  }
}

/// Encodes [lines] as an RFC 4180 CSV string with:
///   - UTF-8 BOM prefix
///   - Header row
///   - CRLF line endings throughout
///
/// Exposed as a top-level function so it can be called from tests and the
/// bytes/file variants above without duplication.
String buildOrderCsvString(List<OrderLine> lines) {
  final buf = StringBuffer(_kBom);

  // Header
  buf.write(_headers.map(_csvField).join(','));
  buf.write('\r\n');

  // Data rows
  for (final line in lines) {
    buf.write([
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
    buf.write('\r\n');
  }

  return buf.toString();
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// RFC 4180 field encoder.
///
/// Wraps in double-quotes when the value contains a comma, double-quote,
/// carriage-return, or newline. Escapes embedded double-quotes as `""`.
String _csvField(Object? value) {
  final s = value?.toString() ?? '';
  if (s.contains(',') ||
      s.contains('"') ||
      s.contains('\r') ||
      s.contains('\n')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

// Keep private alias so callers of the old internal name still compile.
// ignore: unused_element
final _headers = _kHeaders;
