import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/features/catalogue/catalogue_screen.dart';
import 'package:shelfsense/ml/common/thresholds.dart';

void main() {
  group('enrolStateFor', () {
    test('zero embeddings is not enrolled', () {
      expect(enrolStateFor(0), EnrolState.none);
    });
    test('below the minimum is partial', () {
      expect(enrolStateFor(1), EnrolState.partial);
      expect(enrolStateFor(kMinEnrolShots - 1), EnrolState.partial);
    });
    test('at or above the minimum is enrolled', () {
      expect(enrolStateFor(kMinEnrolShots), EnrolState.enrolled);
      expect(enrolStateFor(8), EnrolState.enrolled);
    });
  });
}
