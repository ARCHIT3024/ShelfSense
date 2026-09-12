/// On-device XLSX generation — T-08.
///
/// No server ever touches this file: it is built and written entirely on the
/// handset via Syncfusion's pure-Dart xlsio engine, then handed off through
/// the share sheet or the local HTTP server (T-30).
///
/// Exit criterion (T-08): [writeHelloWorldXlsx] must produce a file that
/// opens in Excel/Sheets with no trial watermark on the physical iQOO device.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../core/failures.dart';
import '../core/logger.dart';
import '../core/result.dart';
import '../domain/models/models.dart';

const _tag = 'XlsxBuilder';

// Licence: used under the Syncfusion Community Licence, registered by Archit
// on 12 Sep 2026 (see ATTRIBUTION.md). xlsio 34.2.7 has no registerLicense
// API; generated files were checked and carry no watermark text.

// Design tokens (mirror AppColors in theme.dart)
const _kHeaderBg    = '#1A237E';
const _kHeaderFg    = '#FFFFFF';
const _kZebraEven   = '#E8EAF6';
const _kZebraOdd    = '#FFFFFF';
const _kAmberTint   = '#FFF9C4';
const _kSubduedFg   = '#616161';
const _kBorderColor = '#BDBDBD';

const _kHeaders = [
  'SKU Code', 'SKU Name', 'Grammage', 'MRP (Rs)', 'Case Size',
  'Suggested Qty', 'Final Qty', 'Unit', 'Value (Rs)', 'Overridden',
];

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Builds a styled order-draft workbook and writes it to app storage.
/// Returns the absolute file path on success, or [ExportFailed] on error.
/// Never throws across the service boundary.
Future<Result<String, Failure>> buildOrderXlsx({
  required String storeName,
  required String storeCode,
  required String beatName,
  required List<OrderLine> lines,
}) async {
  if (lines.isEmpty) {
    return Err(const ExportFailed('Cannot export: order has no lines.'));
  }
  try {
    final bytes = _buildWorkbookBytes(
      storeName: storeName, storeCode: storeCode, beatName: beatName, lines: lines,
    );
    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(dir.path, 'exports'));
    if (!await exportsDir.exists()) await exportsDir.create(recursive: true);
    final fileName =
        'order_${storeCode}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(p.join(exportsDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    AppLogger.i(_tag, 'Wrote ${file.path} (${lines.length} lines)');
    return Ok(file.path);
  } catch (e, st) {
    AppLogger.e(_tag, 'XLSX build failed', e);
    return Err(ExportFailed('XLSX build failed: $e\n$st'));
  }
}

/// Returns raw XLSX bytes without touching the filesystem.
/// Use with share_plus / printing APIs, or in unit tests.
Result<Uint8List, Failure> buildOrderXlsxBytes({
  required String storeName,
  required String storeCode,
  required String beatName,
  required List<OrderLine> lines,
}) {
  if (lines.isEmpty) {
    return Err(const ExportFailed('Cannot export: order has no lines.'));
  }
  try {
    return Ok(_buildWorkbookBytes(
      storeName: storeName, storeCode: storeCode, beatName: beatName, lines: lines,
    ));
  } catch (e, st) {
    AppLogger.e(_tag, 'XLSX bytes build failed', e);
    return Err(ExportFailed('XLSX build failed: $e\n$st'));
  }
}

/// Smoke-test helper for T-08 exit criterion.
/// Wire to a button on the Export screen; open result on device to confirm
/// there is no Syncfusion trial watermark.
Future<Result<String, Failure>> writeHelloWorldXlsx() {
  return buildOrderXlsx(
    storeName: 'Demo Kirana Store',
    storeCode: 'DEMO-001',
    beatName: 'Demo Beat',
    lines: const [
      OrderLine(
        id: 'demo-1', visitId: 'demo-visit', skuId: 'demo-sku',
        skuName: 'Sample Namkeen 200g', skuCode: 'SKU-001',
        grammageLabel: '200 g', mrpPaise: 4500, caseSize: 12,
        suggestedQty: 2, finalQty: 2, unit: 'case',
        valuePaise: 9000, wasOverridden: false, createdAt: 0,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

Uint8List _buildWorkbookBytes({
  required String storeName,
  required String storeCode,
  required String beatName,
  required List<OrderLine> lines,
}) {
  final workbook = xlsio.Workbook();
  _buildSheet(workbook: workbook, storeName: storeName,
      storeCode: storeCode, beatName: beatName, lines: lines);
  final bytes = Uint8List.fromList(workbook.saveAsStream());
  workbook.dispose();
  return bytes;
}

void _buildSheet({
  required xlsio.Workbook workbook,
  required String storeName,
  required String storeCode,
  required String beatName,
  required List<OrderLine> lines,
}) {
  final sheet = workbook.worksheets[0];
  sheet.name = 'Order Draft';
  sheet.showGridlines = false;

  _writeInfoBlock(sheet, storeName, storeCode, beatName);

  const headerRow = 6;
  _writeColumnHeaders(sheet, headerRow);
  // freezePanes() in xlsio 34.x is called on a Range, not the Worksheet.
  // Freezing at A7 keeps the 6-row header block always visible.
  sheet.getRangeByIndex(headerRow + 1, 1).freezePanes();

  var row = headerRow + 1;
  for (final line in lines) {
    _writeDataRow(sheet, row, line);
    row++;
  }
  _writeTotalsRow(sheet, row, lines);

  for (var c = 1; c <= _kHeaders.length; c++) {
    sheet.autoFitColumn(c);
  }
}

void _writeInfoBlock(
  xlsio.Worksheet sheet, String storeName, String storeCode, String beatName,
) {
  final fmt = DateFormat('dd MMM yyyy, HH:mm');

  final t = sheet.getRangeByName('A1');
  t.setText('ShelfSense — Order Draft');
  t.cellStyle..bold = true..fontSize = 14..fontColor = _kHeaderBg;

  final b = sheet.getRangeByName('A2');
  b.setText('Beat: $beatName');
  b.cellStyle.bold = true;

  final s = sheet.getRangeByName('A3');
  s.setText('Store: $storeName  [$storeCode]');
  s.cellStyle.bold = true;

  final ts = sheet.getRangeByName('A4');
  ts.setText('Generated: ${fmt.format(DateTime.now())}');
  ts.cellStyle.fontColor = _kSubduedFg;
}

void _writeColumnHeaders(xlsio.Worksheet sheet, int row) {
  for (var c = 0; c < _kHeaders.length; c++) {
    final cell = sheet.getRangeByIndex(row, c + 1);
    cell.setText(_kHeaders[c]);
    cell.cellStyle
      ..bold = true
      ..backColor = _kHeaderBg
      ..fontColor = _kHeaderFg
      ..hAlign = xlsio.HAlignType.center
      ..borders.bottom.lineStyle = xlsio.LineStyle.medium;
  }
}

void _writeDataRow(xlsio.Worksheet sheet, int row, OrderLine line) {
  final bg = (row % 2 == 0) ? _kZebraEven : _kZebraOdd;

  void txt(int col, String? v) {
    final r = sheet.getRangeByIndex(row, col);
    r.setText(v ?? '');
    r.cellStyle..backColor = bg
      ..borders.bottom.lineStyle = xlsio.LineStyle.thin
      ..borders.bottom.color = _kBorderColor;
  }

  void num(int col, double v, {String? fmt}) {
    final r = sheet.getRangeByIndex(row, col);
    r.setNumber(v);
    if (fmt != null) r.numberFormat = fmt;
    r.cellStyle..backColor = bg
      ..borders.bottom.lineStyle = xlsio.LineStyle.thin
      ..borders.bottom.color = _kBorderColor;
  }

  txt(1, line.skuCode);
  txt(2, line.skuName);
  txt(3, line.grammageLabel);
  num(4, line.mrpPaise / 100.0, fmt: '#,##0.00');
  num(5, line.caseSize.toDouble());
  num(6, line.suggestedQty.toDouble());

  // Final Qty — amber when rep overrode the ML suggestion
  final qtyCell = sheet.getRangeByIndex(row, 7);
  qtyCell.setNumber(line.finalQty.toDouble());
  qtyCell.cellStyle
    ..backColor = line.wasOverridden ? _kAmberTint : bg
    ..bold = line.wasOverridden
    ..borders.bottom.lineStyle = xlsio.LineStyle.thin
    ..borders.bottom.color = _kBorderColor;

  txt(8, line.unit);
  num(9, line.valueRupees, fmt: '#,##0.00');
  txt(10, line.wasOverridden ? 'Y' : 'N');
}

void _writeTotalsRow(xlsio.Worksheet sheet, int row, List<OrderLine> lines) {
  final totalUnits  = lines.fold<int>(0, (s, l) => s + l.finalQty);
  final grandTotal  = lines.fold<double>(0, (s, l) => s + l.valueRupees);
  final overrides   = lines.where((l) => l.wasOverridden).length;

  void tot(int col, {String? text, double? number, String? fmt}) {
    final r = sheet.getRangeByIndex(row, col);
    if (text != null) r.setText(text);
    if (number != null) { r.setNumber(number); if (fmt != null) r.numberFormat = fmt; }
    r.cellStyle
      ..bold = true
      ..backColor = _kHeaderBg
      ..fontColor = _kHeaderFg
      ..borders.top.lineStyle = xlsio.LineStyle.medium;
  }

  tot(1, text: 'TOTALS');
  tot(2, text: '${lines.length} SKU(s)');
  tot(3, text: ''); tot(4, text: ''); tot(5, text: ''); tot(6, text: '');
  tot(7, number: totalUnits.toDouble());
  tot(8, text: '');
  tot(9, number: grandTotal, fmt: '#,##0.00');
  tot(10, text: overrides > 0 ? '$overrides override(s)' : '');
}
