/// On-device XLSX generation — T-08.
///
/// No server ever touches this file: it is built and written entirely on the
/// handset via Syncfusion's pure-Dart xlsio engine, then handed off through
/// the share sheet or the local HTTP server (T-30).
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../core/failures.dart';
import '../core/logger.dart';
import '../core/result.dart';
import '../domain/models/models.dart';

const _tag = 'XlsxBuilder';

// NOTE (T-08 licence check, verified in this session): syncfusion_flutter_xlsio
// 34.2.7 has no `registerLicense`/`SyncfusionLicense` API to call — there is
// no in-code key. The obligation is still real: you must sign up for the
// free Syncfusion Community Licence (https://www.syncfusion.com/products/communitylicense)
// — gross revenue < $1M, <5 developers — and note that in ATTRIBUTION.md.
// Open the first real export on-device and confirm there is no watermark;
// if one appears, fall back to the `excel` package or CSV + PDF only
// (see docs/Work Flow.md §9 risk register).

/// Builds the order-draft workbook for one visit and writes it to app
/// storage. Returns the absolute file path on success.
Future<Result<String, Failure>> buildOrderXlsx({
  required String storeName,
  required String storeCode,
  required String beatName,
  required List<OrderLine> lines,
}) async {
  try {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Order Draft';

    sheet.getRangeByName('A1').setText('ShelfSense — Order Draft');
    sheet.getRangeByName('A2').setText('Beat: $beatName');
    sheet.getRangeByName('A3').setText('Store: $storeName ($storeCode)');
    sheet
        .getRangeByName('A4')
        .setText('Generated: ${DateTime.now().toIso8601String()}');

    const headerRow = 6;
    const headers = [
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
    for (var c = 0; c < headers.length; c++) {
      sheet.getRangeByIndex(headerRow, c + 1).setText(headers[c]);
    }

    var row = headerRow + 1;
    for (final line in lines) {
      var col = 1;
      sheet.getRangeByIndex(row, col++).setText(line.skuCode ?? '');
      sheet.getRangeByIndex(row, col++).setText(line.skuName ?? '');
      sheet.getRangeByIndex(row, col++).setText(line.grammageLabel ?? '');
      sheet.getRangeByIndex(row, col++).setNumber(line.mrpPaise / 100.0);
      sheet.getRangeByIndex(row, col++).setNumber(line.caseSize.toDouble());
      sheet
          .getRangeByIndex(row, col++)
          .setNumber(line.suggestedQty.toDouble());
      sheet.getRangeByIndex(row, col++).setNumber(line.finalQty.toDouble());
      sheet.getRangeByIndex(row, col++).setText(line.unit);
      sheet.getRangeByIndex(row, col++).setNumber(line.valueRupees);
      sheet.getRangeByIndex(row, col++).setText(line.wasOverridden ? 'Y' : 'N');
      row++;
    }

    for (var c = 1; c <= headers.length; c++) {
      sheet.autoFitColumn(c);
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(dir.path, 'exports'));
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }
    final fileName =
        'order_${storeCode}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(p.join(exportsDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);

    AppLogger.i(_tag, 'Wrote ${file.path} (${lines.length} lines)');
    return Ok(file.path);
  } catch (e) {
    AppLogger.e(_tag, 'XLSX build failed', e);
    return Err(ExportFailed('XLSX build failed: $e'));
  }
}

/// Smoke-test helper for T-08's exit criterion ("a hello-world .xlsx").
/// Wire a button to this from the Export screen and open the result to
/// confirm there is no Syncfusion trial watermark.
Future<Result<String, Failure>> writeHelloWorldXlsx() {
  return buildOrderXlsx(
    storeName: 'Demo Kirana Store',
    storeCode: 'DEMO-001',
    beatName: 'Demo Beat',
    lines: const [
      OrderLine(
        id: 'demo-1',
        visitId: 'demo-visit',
        skuId: 'demo-sku',
        skuName: 'Sample Namkeen 200g',
        skuCode: 'SKU-001',
        grammageLabel: '200 g',
        mrpPaise: 4500,
        caseSize: 12,
        suggestedQty: 2,
        finalQty: 2,
        unit: 'case',
        valuePaise: 9000,
        wasOverridden: false,
        createdAt: 0,
      ),
    ],
  );
}
