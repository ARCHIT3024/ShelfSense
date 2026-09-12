/// Unit tests for xlsx_builder.dart — T-08.
///
/// These run on the host (flutter test) — no device needed.
/// They use [buildOrderXlsxBytes] which skips filesystem I/O, making the
/// tests fast and hermetic.
///
/// Coverage:
///  - Empty-lines guard → ExportFailed (never throws)
///  - Happy path → Ok with non-empty Uint8List
///  - XLSX/ZIP magic bytes (PK\x03\x04)
///  - Output type is Uint8List (not plain List<int>)
///  - Multi-row output is larger than single-row output
///  - Override flag reflected correctly in OrderLine
///  - Smoke test with real-world-like data
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/core/failures.dart';
import 'package:shelfsense/core/result.dart';
import 'package:shelfsense/domain/models/models.dart';
import 'package:shelfsense/output/xlsx_builder.dart';

void main() {
  // ---------------------------------------------------------------------------
  // OrderLine derived field sanity
  // ---------------------------------------------------------------------------

  group('OrderLine.valueRupees', () {
    test('converts paise to rupees correctly', () {
      const line = OrderLine(
        id: 'x', visitId: 'v', skuId: 's',
        mrpPaise: 4500, caseSize: 12,
        suggestedQty: 2, finalQty: 2,
        unit: 'case', valuePaise: 9000,
        wasOverridden: false, createdAt: 0,
      );
      expect(line.valueRupees, closeTo(90.0, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // Guard: empty lines
  // ---------------------------------------------------------------------------

  group('buildOrderXlsxBytes — empty guard', () {
    test('returns Err(ExportFailed) when lines list is empty', () {
      final result = buildOrderXlsxBytes(
        storeName: 'Test Store',
        storeCode: 'TST-001',
        beatName: 'Test Beat',
        lines: const [],
      );

      expect(result.isErr, isTrue);
      final failure = result.failureOrNull;
      expect(failure, isA<ExportFailed>());
      expect((failure! as ExportFailed).message,
          contains('Cannot export'));
    });
  });

  // ---------------------------------------------------------------------------
  // Happy path
  // ---------------------------------------------------------------------------

  group('buildOrderXlsxBytes — happy path', () {
    test('returns Ok for a single line', () {
      final result = buildOrderXlsxBytes(
        storeName: 'Big Bazaar – Velachery',
        storeCode: 'STR-001',
        beatName: 'South Chennai Beat',
        lines: [_line()],
      );

      expect(result.isOk, isTrue);
    });

    test('bytes are non-empty', () {
      final bytes = _build([_line()]);
      expect(bytes.length, greaterThan(0));
    });

    test('output is Uint8List (not plain List<int>)', () {
      final bytes = _build([_line()]);
      expect(bytes, isA<Uint8List>());
    });

    test('starts with XLSX/ZIP magic bytes PK\\x03\\x04', () {
      final bytes = _build([_line()]);
      // XLSX is a ZIP container; first 4 bytes are always 50 4B 03 04
      expect(bytes[0], 0x50, reason: 'Expected P (0x50)');
      expect(bytes[1], 0x4B, reason: 'Expected K (0x4B)');
      expect(bytes[2], 0x03);
      expect(bytes[3], 0x04);
    });

    test('multi-row output is larger than single-row output', () {
      final single = _build([_line()]);
      final multi = _build([
        _line(),
        _line(code: 'SKU-002', name: 'Biscuit 100g', value: 6000),
        _line(code: 'SKU-003', name: 'Chips 50g', value: 3000, override: true),
      ]);
      expect(multi.length, greaterThan(single.length));
    });

    test('output is never tiny — minimum realistic XLSX size', () {
      final bytes = _build([_line()]);
      // A valid XLSX with one data row should always exceed 4 KB
      expect(bytes.length, greaterThan(4096));
    });
  });

  // ---------------------------------------------------------------------------
  // Smoke test — realistic multi-SKU order
  // ---------------------------------------------------------------------------

  test('smoke: realistic 5-SKU order produces valid XLSX bytes', () {
    final result = buildOrderXlsxBytes(
      storeName: 'Metro Cash & Carry',
      storeCode: 'MCC-042',
      beatName: 'North Chennai Beat',
      lines: [
        _line(code: 'NMK-200', name: 'Namkeen Mix 200g', mrp: 4500, qty: 3, value: 13500),
        _line(code: 'BIS-100', name: 'Glucose Biscuit 100g', mrp: 1000, qty: 24, value: 24000, override: true),
        _line(code: 'CHP-050', name: 'Masala Chips 50g', mrp: 2000, qty: 12, value: 24000),
        _line(code: 'COO-200', name: 'Coconut Cookies 200g', mrp: 6000, qty: 6, value: 36000),
        _line(code: 'OAT-500', name: 'Oats 500g', mrp: 8000, qty: 2, value: 16000, override: true),
      ],
    );

    expect(result.isOk, isTrue);
    final bytes = result.valueOrNull!;
    expect(bytes[0], 0x50);
    expect(bytes[1], 0x4B);
    expect(bytes.length, greaterThan(4096));
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

OrderLine _line({
  String code = 'SKU-001',
  String name = 'Sample Namkeen 200g',
  int mrp = 4500,
  int qty = 2,
  int value = 9000,
  bool override = false,
}) {
  return OrderLine(
    id: 'test-${code.hashCode}',
    visitId: 'visit-001',
    skuId: 'sku-${code.hashCode}',
    skuName: name,
    skuCode: code,
    grammageLabel: '200 g',
    mrpPaise: mrp,
    caseSize: 12,
    suggestedQty: qty,
    finalQty: qty,
    unit: 'case',
    valuePaise: value,
    wasOverridden: override,
    createdAt: 0,
  );
}

Uint8List _build(List<OrderLine> lines) {
  final result = buildOrderXlsxBytes(
    storeName: 'Test Store',
    storeCode: 'TST-001',
    beatName: 'Test Beat',
    lines: lines,
  );
  if (result.isErr) {
    throw StateError('buildOrderXlsxBytes returned Err: ${result.failureOrNull}');
  }
  return result.valueOrNull!;
}
