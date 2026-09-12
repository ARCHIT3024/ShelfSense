import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/ml/common/thresholds.dart';

void main() {
  group('RuntimeThresholds', () {
    test('defaults are the k* constants', () {
      final t = RuntimeThresholds();
      expect(t.detConf, kDetConfThreshold);
      expect(t.detNmsIou, kDetNmsIou);
      expect(t.detMaxBoxes, kDetMaxBoxes);
      expect(t.matchHigh, kMatchHigh);
      expect(t.matchLow, kMatchLow);
    });

    test('applySettings reads app_settings rows and ignores junk', () {
      final t = RuntimeThresholds();
      t.applySettings({
        RuntimeThresholds.keyDetConf: '0.5',
        RuntimeThresholds.keyDetNmsIou: 'not a number',
        RuntimeThresholds.keyDetMaxBoxes: '50',
        RuntimeThresholds.keyMatchHigh: '0.8',
        RuntimeThresholds.keyMatchLow: '0.6',
      });
      expect(t.detConf, 0.5);
      expect(t.detNmsIou, kDetNmsIou); // unparsable → unchanged
      expect(t.detMaxBoxes, 50);
      expect(t.matchHigh, 0.8);
      expect(t.matchLow, 0.6);
    });

    test('applySettings clamps and repairs an inverted match pair', () {
      final t = RuntimeThresholds();
      t.applySettings({
        RuntimeThresholds.keyDetConf: '5',
        RuntimeThresholds.keyMatchHigh: '0.5',
        RuntimeThresholds.keyMatchLow: '0.9',
      });
      expect(t.detConf, 0.95);
      expect(t.matchHigh, 0.5);
      expect(t.matchLow, closeTo(0.49, 1e-9));
    });

    test('setters persist with the app_settings keys', () async {
      final saved = <String, String>{};
      final t = RuntimeThresholds(persist: (k, v) async => saved[k] = v);
      await t.setDetConf(0.4);
      await t.setDetNmsIou(0.6);
      expect(saved[RuntimeThresholds.keyDetConf], '0.4');
      expect(saved[RuntimeThresholds.keyDetNmsIou], '0.6');
    });

    test('accept and reject never cross', () async {
      final t = RuntimeThresholds();
      await t.setMatchLow(0.9); // above the 0.72 accept
      expect(t.matchHigh, greaterThan(t.matchLow));
      await t.setMatchHigh(0.3); // below the reject
      expect(t.matchLow, lessThan(t.matchHigh));
    });

    test('resetToDefaults restores constants and notifies listeners', () async {
      final t = RuntimeThresholds();
      var notified = 0;
      t.addListener(() => notified++);
      await t.setDetConf(0.9);
      await t.resetToDefaults();
      expect(t.detConf, kDetConfThreshold);
      expect(t.matchLow, kMatchLow);
      expect(notified, greaterThan(1));
    });
  });
}
