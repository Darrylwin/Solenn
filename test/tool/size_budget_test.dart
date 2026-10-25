import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/size_budget.dart';

void main() {
  group('sizeViolation', () {
    test('should accept a size within the budget', () {
      expect(sizeViolation(10 * 1024 * 1024), isNull);
    });

    test('should accept exactly the budget', () {
      expect(sizeViolation(maxArm64ApkBytes), isNull);
    });

    test('should report a size over the budget', () {
      final message = sizeViolation(26 * 1024 * 1024);

      expect(message, contains('26.0 MiB'));
      expect(message, contains('25.0 MiB'));
    });

    test('should honor a custom budget', () {
      expect(sizeViolation(2000, budget: 1000), isNotNull);
      expect(sizeViolation(500, budget: 1000), isNull);
    });
  });

  group('formatMebibytes', () {
    test('should format with one decimal', () {
      expect(formatMebibytes(1572864), '1.5 MiB');
      expect(formatMebibytes(0), '0.0 MiB');
    });
  });
}
