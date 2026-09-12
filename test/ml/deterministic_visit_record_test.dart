import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/domain/models/models.dart';
import 'package:shelfsense/ml/llm/deterministic_visit_record.dart';

ShelfFact _fact(String sku, ShelfStatus s) => ShelfFact(
      id: 'f-$sku', visitId: 'v', skuId: sku, skuName: sku,
      detectedFacings: 0, targetFacings: 2, status: s, computedAt: 0,
    );

OrderLine _line(String sku, int sug, int fin) => OrderLine(
      id: 'l-$sku', visitId: 'v', skuId: sku, skuName: sku, mrpPaise: 5500,
      caseSize: 24, suggestedQty: sug, finalQty: fin, unit: 'unit',
      valuePaise: fin * 5500, wasOverridden: sug != fin, createdAt: 0,
    );

void main() {
  const svc = DeterministicVisitRecordService();

  test('facts are counted from the data', () {
    final f = svc.facts(
      shelfFacts: [
        _fact('a', ShelfStatus.stockout),
        _fact('b', ShelfStatus.stockout),
        _fact('c', ShelfStatus.belowPlan),
        _fact('d', ShelfStatus.unlisted),
      ],
      lines: [_line('a', 24, 48), _line('b', 24, 24)],
    );
    expect(f.stockouts, 2);
    expect(f.belowPlan, 1);
    expect(f.unlisted, 1);
    expect(f.lineCount, 2);
    expect(f.totalValuePaise, 72 * 5500);
    expect(f.overrides, [('a', 24, 48)]);
    expect(f.toJson()['stockouts'], 2);
  });

  test('summary and rationale read like the spec example', () {
    final rec = svc.record(
      shelfFacts: [
        for (var i = 0; i < 6; i++) _fact('s$i', ShelfStatus.stockout),
        _fact('bp', ShelfStatus.belowPlan),
      ],
      lines: [
        _line('Dust Tea', 24, 48),
        for (var i = 0; i < 7; i++) _line('x$i', 12, 12),
      ],
    );
    expect(rec.summaryProse, '6 SKUs out of stock, 1 below plan.');
    expect(rec.reorderRationale,
        startsWith('Suggested reorder of 8 lines worth ₹'));
    expect(rec.reorderRationale,
        contains('Dust Tea raised from 24 to 48 by the rep'));
    expect(rec.reorderRationale, isNot(contains('AI')));
  });

  test('no planogram, no lines', () {
    final rec = svc.record(shelfFacts: const [], lines: const []);
    expect(rec.summaryProse, 'No planogram data for this visit.');
    expect(rec.reorderRationale, contains('No reorder'));
  });

  test('transcript is appended, long notes are trimmed', () {
    final rec = svc.record(
      shelfFacts: [_fact('a', ShelfStatus.inStock)],
      lines: const [],
      transcript: 'x' * 400,
    );
    expect(rec.summaryProse, contains('Owner note: '));
    expect(rec.summaryProse.length, lessThan(220));
    expect(rec.reorderRationale,
        'No reorder needed — planogram lines are in stock.');
  });

  test('added lines (suggested 0) are described as added', () {
    final lines = [_line('Soap', 0, 24)];
    final f = svc.facts(shelfFacts: const [], lines: lines);
    final r = svc.rationale(f, shelfFacts: const [], lines: lines);
    expect(r, contains('Soap added at 24'));
  });
}
