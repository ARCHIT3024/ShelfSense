// pdf_builder_test.dart — T-29 (LLM-free half)
//
// Verifies the beat summary PDF builds from domain data alone, without
// touching the filesystem or asset bundle (built-in font).
import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/core/failures.dart';
import 'package:shelfsense/core/result.dart';
import 'package:shelfsense/domain/models/models.dart';
import 'package:shelfsense/output/pdf_builder.dart';

ShelfFact _fact(String sku, ShelfStatus s, {int plan = 4, int found = 0}) =>
    ShelfFact(
      id: 'f-$sku', visitId: 'v1', skuId: 'sku-$sku', skuName: sku,
      skuCode: sku.toUpperCase(), grammageLabel: '100 g',
      detectedFacings: found, targetFacings: plan, status: s, computedAt: 0,
    );

OrderLine _line(String sku, int sug, int fin, {int mrp = 1500}) => OrderLine(
      id: 'l-$sku', visitId: 'v1', skuId: 'sku-$sku', skuName: sku,
      skuCode: sku.toUpperCase(), grammageLabel: '100 g', mrpPaise: mrp,
      caseSize: 12, suggestedQty: sug, finalQty: fin, unit: 'unit',
      valuePaise: fin * mrp, wasOverridden: sug != fin, createdAt: 0,
    );

final _visit = PdfVisit(
  storeName: 'Kumar Stores',
  storeCode: 'KIR-0101',
  confirmedAt: DateTime(2026, 9, 12, 18, 23),
  shelfFacts: [
    _fact('Dust Tea', ShelfStatus.stockout),
    _fact('Iodized Salt', ShelfStatus.belowPlan, found: 1),
    _fact('Basmati Rice', ShelfStatus.inStock, found: 4),
    _fact('Bath Soap', ShelfStatus.unlisted, plan: 0, found: 1),
  ],
  lines: [_line('Dust Tea', 24, 48), _line('Iodized Salt', 12, 12)],
);

void main() {
  group('buildBeatSummaryPdfBytes', () {
    test('empty visits → Err(ExportFailed)', () async {
      final r = await buildBeatSummaryPdfBytes(
          beatName: 'B', beatCode: 'BEAT-1', visits: const []);
      expect(r.isErr, isTrue);
      expect(r.failureOrNull, isA<ExportFailed>());
    });

    test('produces a real PDF from one visit', () async {
      final r = await buildBeatSummaryPdfBytes(
        beatName: 'Anna Nagar East Beat',
        beatCode: 'BEAT-12',
        repName: 'Ravi Kumar',
        visits: [_visit],
      );
      expect(r.isOk, isTrue, reason: '${r.failureOrNull}');
      final bytes = r.valueOrNull!;
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(2000));
    });

    test('scales to a full beat and keeps a trailer', () async {
      final visits = [
        for (var i = 0; i < 12; i++)
          PdfVisit(
            storeName: 'Store $i',
            storeCode: 'KIR-01${i.toString().padLeft(2, '0')}',
            confirmedAt: DateTime(2026, 9, 12, 10 + i ~/ 2),
            shelfFacts: _visit.shelfFacts,
            lines: _visit.lines,
          ),
      ];
      final r = await buildBeatSummaryPdfBytes(
          beatName: 'Beat', beatCode: 'B', visits: visits);
      final bytes = r.valueOrNull!;
      final tail = String.fromCharCodes(bytes.skip(bytes.length - 64));
      expect(tail, contains('%%EOF'));
      expect(bytes.length, greaterThan(10000));
    });
  });
}
