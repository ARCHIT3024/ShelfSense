/// Unit tests for csv_builder.dart — T-09.
///
/// All tests run on the host (flutter test) — no device or filesystem needed.
/// They use [buildOrderCsvString] and [buildOrderCsvBytes] which are pure
/// in-memory functions.
///
/// Coverage:
///  1. Empty guard → ExportFailed (both bytes and string variants)
///  2. Output starts with UTF-8 BOM (\uFEFF)
///  3. Header row is present and correct
///  4. Data row count matches input (1 header + N data + nothing extra)
///  5. CRLF line endings throughout (RFC 4180)
///  6. Numeric formatting: MRP and value to 2 decimal places
///  7. Overridden flag: Y / N
///  8. RFC 4180 quoting: commas in fields
///  9. RFC 4180 quoting: double-quotes in fields
/// 10. RFC 4180 quoting: newlines in fields
/// 11. buildOrderCsvBytes returns Uint8List starting with UTF-8 BOM bytes
/// 12. Multi-row smoke test — realistic 4-SKU order
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/core/failures.dart';
import 'package:shelfsense/core/result.dart';
import 'package:shelfsense/domain/models/models.dart';
import 'package:shelfsense/output/csv_builder.dart';

void main() {
  // ── Helpers ────────────────────────────────────────────────────────────────

  OrderLine line({
    String code = 'SKU-001',
    String name = 'Namkeen 200g',
    String grammage = '200 g',
    int mrp = 4500,
    int caseSize = 12,
    int sugQty = 2,
    int finalQty = 2,
    String unit = 'case',
    int valuePaise = 9000,
    bool overridden = false,
  }) =>
      OrderLine(
        id: 'id-$code',
        visitId: 'v1',
        skuId: 'sku-$code',
        skuCode: code,
        skuName: name,
        grammageLabel: grammage,
        mrpPaise: mrp,
        caseSize: caseSize,
        suggestedQty: sugQty,
        finalQty: finalQty,
        unit: unit,
        valuePaise: valuePaise,
        wasOverridden: overridden,
        createdAt: 0,
      );

  // Split on CRLF, keep header + data rows (drop trailing empty after last \r\n)
  List<String> rows(String csv) {
    // Skip the BOM if present
    final clean = csv.startsWith('\uFEFF') ? csv.substring(1) : csv;
    final parts = clean.split('\r\n');
    return parts.where((r) => r.isNotEmpty).toList();
  }

  // ── 1. Empty guard ─────────────────────────────────────────────────────────

  group('Empty guard', () {
    test('buildOrderCsvBytes returns ExportFailed for empty lines', () {
      final result = buildOrderCsvBytes(lines: const []);
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ExportFailed>());
    });

    test('buildOrderCsvString still works with empty list (no guard there)', () {
      // buildOrderCsvString is a lower-level helper; the guard is in the
      // public APIs. Calling it with [] should produce only a header row.
      final csv = buildOrderCsvString(const []);
      final r = rows(csv);
      expect(r.length, 1); // header only
    });
  });

  // ── 2. UTF-8 BOM ──────────────────────────────────────────────────────────

  group('UTF-8 BOM', () {
    test('buildOrderCsvString starts with BOM character', () {
      final csv = buildOrderCsvString([line()]);
      expect(csv.startsWith('\uFEFF'), isTrue,
          reason: 'First char must be BOM so Excel auto-detects UTF-8');
    });

    test('buildOrderCsvBytes starts with UTF-8 BOM bytes (EF BB BF)', () {
      final result = buildOrderCsvBytes(lines: [line()]);
      expect(result.isOk, isTrue);
      final bytes = result.valueOrNull!;
      expect(bytes[0], 0xEF);
      expect(bytes[1], 0xBB);
      expect(bytes[2], 0xBF);
    });

    test('buildOrderCsvBytes returns Uint8List', () {
      final result = buildOrderCsvBytes(lines: [line()]);
      expect(result.valueOrNull, isA<Uint8List>());
    });
  });

  // ── 3. Header row ──────────────────────────────────────────────────────────

  group('Header row', () {
    test('first data row is the correct header', () {
      final csv = buildOrderCsvString([line()]);
      final r = rows(csv);
      expect(r.first, contains('SKU Code'));
      expect(r.first, contains('SKU Name'));
      expect(r.first, contains('MRP'));
      expect(r.first, contains('Value'));
      expect(r.first, contains('Overridden'));
    });

    test('header has exactly 10 columns', () {
      final csv = buildOrderCsvString([line()]);
      final header = rows(csv).first;
      expect(header.split(',').length, 10);
    });
  });

  // ── 4. Row count ───────────────────────────────────────────────────────────

  group('Row count', () {
    test('single line → 2 rows (header + 1 data)', () {
      final csv = buildOrderCsvString([line()]);
      expect(rows(csv).length, 2);
    });

    test('three lines → 4 rows (header + 3 data)', () {
      final csv = buildOrderCsvString([line(), line(code: 'B'), line(code: 'C')]);
      expect(rows(csv).length, 4);
    });
  });

  // ── 5. CRLF line endings ───────────────────────────────────────────────────

  group('CRLF line endings', () {
    test('every line ending is CRLF, not bare LF', () {
      final csv = buildOrderCsvString([line()]);
      // Should contain \r\n
      expect(csv.contains('\r\n'), isTrue);
    });

    test('no bare LF (only CRLF) — RFC 4180 §2', () {
      final csv = buildOrderCsvString([line(), line(code: 'B')]);
      // Remove all \r\n, then check no \n remains
      final stripped = csv.replaceAll('\r\n', '');
      expect(stripped.contains('\n'), isFalse,
          reason: 'Bare LF found — all newlines must be CRLF');
    });
  });

  // ── 6. Numeric formatting ──────────────────────────────────────────────────

  group('Numeric formatting', () {
    test('MRP written as rupees with 2 decimal places', () {
      // mrpPaise = 4567 → "45.67"
      final csv = buildOrderCsvString([line(mrp: 4567)]);
      expect(csv, contains('45.67'));
    });

    test('Value written as rupees with 2 decimal places', () {
      // valuePaise = 9001 → "90.01"
      final csv = buildOrderCsvString([line(valuePaise: 9001)]);
      expect(csv, contains('90.01'));
    });
  });

  // ── 7. Overridden flag ─────────────────────────────────────────────────────

  group('Overridden flag', () {
    test('wasOverridden: false → N in last column', () {
      final csv = buildOrderCsvString([line(overridden: false)]);
      final dataRow = rows(csv)[1];
      expect(dataRow.split(',').last, 'N');
    });

    test('wasOverridden: true → Y in last column', () {
      final csv = buildOrderCsvString([line(overridden: true)]);
      final dataRow = rows(csv)[1];
      expect(dataRow.split(',').last, 'Y');
    });
  });

  // ── 8-10. RFC 4180 quoting ─────────────────────────────────────────────────

  group('RFC 4180 quoting', () {
    test('comma in SKU name is double-quoted', () {
      final csv = buildOrderCsvString([line(name: 'Salt, Sugar & Spice')]);
      expect(csv, contains('"Salt, Sugar & Spice"'));
    });

    test('double-quote in SKU name is escaped as ""', () {
      final csv = buildOrderCsvString([line(name: 'Brand "Special" Pack')]);
      expect(csv, contains('"Brand ""Special"" Pack"'));
    });

    test('newline in grammage label is quoted', () {
      final csv = buildOrderCsvString([line(grammage: '200\ng')]);
      expect(csv, contains('"200\ng"'));
    });

    test('plain field with no special chars is not quoted', () {
      final csv = buildOrderCsvString([line(code: 'SKU001')]);
      // SKU001 has no commas/quotes/newlines — should appear unquoted
      expect(csv, contains('SKU001'));
      expect(csv, isNot(contains('"SKU001"')));
    });
  });

  // ── 11. Round-trip UTF-8 decode ────────────────────────────────────────────

  test('buildOrderCsvBytes round-trips through UTF-8 decode', () {
    final result = buildOrderCsvBytes(
      lines: [line(name: 'Namkeen — Spicy')],
    );
    expect(result.isOk, isTrue);
    final bytes = result.valueOrNull!;
    // Decode skipping BOM
    final decoded = utf8.decode(bytes);
    expect(decoded, contains('Namkeen — Spicy'));
  });

  // ── 12. Smoke test ─────────────────────────────────────────────────────────

  test('smoke: realistic 4-SKU order produces valid CSV', () {
    final lines = [
      line(code: 'NMK-200', name: 'Namkeen Mix 200g',   mrp: 4500, valuePaise: 13500, sugQty: 3, finalQty: 3),
      line(code: 'BIS-100', name: 'Glucose Biscuit 100g', mrp: 1000, valuePaise: 24000, sugQty: 24, finalQty: 20, overridden: true),
      line(code: 'CHP-050', name: 'Masala Chips 50g',    mrp: 2000, valuePaise: 24000, sugQty: 12, finalQty: 12),
      line(code: 'COO-200', name: 'Coconut Cookies, Assorted', mrp: 6000, valuePaise: 36000, sugQty: 6, finalQty: 6),
    ];

    final csv = buildOrderCsvString(lines);
    final r = rows(csv);

    expect(r.length, 5); // header + 4 data
    expect(csv, contains('NMK-200'));
    expect(csv, contains('"Coconut Cookies, Assorted"')); // comma → quoted
    expect(csv, contains('Y')); // overridden line
    expect(csv.startsWith('\uFEFF'), isTrue);
  });
}
