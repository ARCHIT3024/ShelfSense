import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/ml/ocr/grammage_parser.dart';

void main() {
  Grammage g(double b, String f) => Grammage(b, f);

  group('parseGrammages', () {
    test('plain sizes with and without a space', () {
      expect(parseGrammages('Net Wt 450 ml'), [g(450, 'ml')]);
      expect(parseGrammages('70g'), [g(70, 'g')]);
      expect(parseGrammages('NET QTY: 1 kg'), [g(1000, 'g')]);
    });
    test('litres normalise to ml, kg to g', () {
      expect(parseGrammages('1L PET BOTTLE'), [g(1000, 'ml')]);
      expect(parseGrammages('2.25 Litre'), [g(2250, 'ml')]);
      expect(parseGrammages('0.5kg'), [g(500, 'g')]);
    });
    test('OCR noise: O for 0, I for 1, mI for ml', () {
      expect(parseGrammages('45Oml'), [g(450, 'ml')]);
      expect(parseGrammages('450 mI'), [g(450, 'ml')]);
      expect(parseGrammages('1OO g'), [g(100, 'g')]);
      expect(parseGrammages('5I0 g'), [g(510, 'g')]);
    });
    test('counts and alternate unit spellings', () {
      expect(parseGrammages('12 pcs'), [g(12, 'n')]);
      expect(parseGrammages('200 gms'), [g(200, 'g')]);
      expect(parseGrammages('5 ltr'), [g(5000, 'ml')]);
    });
    test('decimal comma', () {
      expect(parseGrammages('1,5 l'), [g(1500, 'ml')]);
    });
    test('multiple sizes in one label are all returned, de-duplicated', () {
      expect(parseGrammages('450 ml  Rs 40  450ml  100 g'),
          [g(450, 'ml'), g(100, 'g')]);
    });
    test('rejects numbers without a unit', () {
      expect(parseGrammages('MRP 45'), isEmpty);
      expect(parseGrammages('MRP Rs. 120.00'), isEmpty);
    });
    test('rejects phone numbers, dates, batch codes', () {
      expect(parseGrammages('Call 9876543210'), isEmpty);
      expect(parseGrammages('MFD 12/2026 EXP 12/2027'), isEmpty);
      expect(parseGrammages('EA SPORTS FC 27 IN-GAME REWARDS'), isEmpty);
      expect(parseGrammages('B.No. L2210'), isEmpty);
    });
    test('unit glued to more letters is not a size', () {
      expect(parseGrammages('45 gsm paper'), isEmpty);
      expect(parseGrammages('500 mg tablet'), isEmpty);
      expect(parseGrammages('Serve chilled'), isEmpty);
    });
    test('absurd magnitudes are dropped', () {
      expect(parseGrammages('202600 g'), isEmpty);
    });
  });

  group('Grammage.fromSku / matches', () {
    test('kg and g compare in the same family', () {
      final kg = Grammage.fromSku(1, 'kg')!;
      expect(kg.matches(g(1000, 'g')), isTrue);
      expect(kg.matches(g(1000, 'ml')), isFalse);
    });
    test('tolerance is 5 percent', () {
      expect(g(450, 'ml').matches(g(470, 'ml')), isTrue);
      expect(g(450, 'ml').matches(g(550, 'ml')), isFalse);
    });
    test('missing value or unit gives null', () {
      expect(Grammage.fromSku(null, 'g'), isNull);
      expect(Grammage.fromSku(1, null), isNull);
    });
  });

  group('pickByGrammage', () {
    final pepsi = [g(450, 'ml'), g(550, 'ml'), g(1000, 'ml')];
    test('picks the single candidate whose size appears', () {
      expect(pickByGrammage(parseGrammages('PEPSI 1L'), pepsi), 2);
      expect(pickByGrammage(parseGrammages('45Oml'), pepsi), 0);
    });
    test('null when nothing matches or more than one matches', () {
      expect(pickByGrammage(parseGrammages('PEPSI'), pepsi), isNull);
      expect(pickByGrammage(parseGrammages('450 ml 550 ml'), pepsi), isNull);
    });
    test('candidates without a size are skipped', () {
      expect(pickByGrammage(parseGrammages('100 g'), [null, g(100, 'g')]), 1);
    });
  });
}
