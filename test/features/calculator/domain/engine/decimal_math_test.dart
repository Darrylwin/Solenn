import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';

Decimal _d(String text) => Decimal.parse(text);

String _rounded(String text, {int digits = significantDigits}) =>
    canonicalText(roundToSignificantDigits(_d(text), digits: digits));

void main() {
  group('canonicalText', () {
    test('should drop trailing zeros after the separator', () {
      expect(canonicalText(_d('1.50')), '1.5');
      expect(canonicalText(_d('10.00')), '10');
      expect(canonicalText(_d('0.0')), '0');
    });

    test('should keep the zeros of an integer', () {
      expect(canonicalText(_d('100')), '100');
    });

    test('should not produce a negative zero', () {
      expect(canonicalText(_d('-0')), '0');
      expect(canonicalText(_d('-0.0')), '0');
    });

    test('should keep the sign and leading zeros of a fraction', () {
      expect(canonicalText(_d('-0.50')), '-0.5');
      expect(canonicalText(_d('0.05')), '0.05');
    });
  });

  group('roundToSignificantDigits', () {
    test('should keep a number that already fits', () {
      expect(_rounded('123456789012345'), '123456789012345');
      expect(_rounded('0.123456789012345'), '0.123456789012345');
      expect(_rounded('0'), '0');
    });

    test('should round half up on the first dropped digit', () {
      expect(_rounded('1234567890123454'), '1234567890123450');
      expect(_rounded('1234567890123455'), '1234567890123460');
      expect(_rounded('1234567890123456'), '1234567890123460');
    });

    test('should round away from zero for negative numbers', () {
      expect(_rounded('-1234567890123454'), '-1234567890123450');
      expect(_rounded('-1234567890123455'), '-1234567890123460');
    });

    test('should round the fractional part', () {
      expect(_rounded('0.1234567890123456'), '0.123456789012346');
      expect(_rounded('0.1234567890123454'), '0.123456789012345');
    });

    test('should not count leading zeros as significant', () {
      expect(
        _rounded('0.00001234567890123456'),
        '0.0000123456789012346',
      );
    });

    test('should carry into a new digit', () {
      expect(_rounded('9999999999999999'), '10000000000000000');
    });

    test('should honor a custom number of digits', () {
      expect(_rounded('12345', digits: 3), '12300');
      expect(_rounded('12355', digits: 3), '12400');
      expect(_rounded('0.0015', digits: 1), '0.002');
    });
  });

  group('isOutOfRange', () {
    test('should accept the extremes of the range', () {
      expect(isOutOfRange(_d('1${'0' * 99}')), isFalse);
      expect(isOutOfRange(_d('0.${'0' * 98}1')), isFalse);
      expect(isOutOfRange(_d('0')), isFalse);
    });

    test('should reject anything beyond, in both directions', () {
      expect(isOutOfRange(_d('1${'0' * 100}')), isTrue);
      expect(isOutOfRange(_d('-1${'0' * 100}')), isTrue);
      expect(isOutOfRange(_d('0.${'0' * 99}1')), isTrue);
    });
  });

  group('divideDecimal', () {
    test('should return null for a zero divisor', () {
      expect(divideDecimal(_d('1'), _d('0')), isNull);
      expect(divideDecimal(_d('1'), _d('0.00')), isNull);
    });

    test('should divide exactly when the quotient is finite', () {
      expect(canonicalText(divideDecimal(_d('1'), _d('4'))!), '0.25');
    });

    test('should keep far more digits than a result needs', () {
      final quotient = divideDecimal(_d('1'), _d('3'))!;

      expect(
        canonicalText(roundToSignificantDigits(quotient)),
        '0.333333333333333',
      );
      expect(canonicalText(quotient).length, greaterThan(50));
    });

    test('should keep a tiny quotient nonzero down to the range limit', () {
      final quotient = divideDecimal(_d('0.${'0' * 98}1'), _d('10'))!;

      expect(canonicalText(quotient), '0.${'0' * 99}1');
    });
  });

  test('percentValue should be one hundredth', () {
    expect(canonicalText(percentValue(_d('50'))), '0.5');
    expect(canonicalText(percentValue(_d('0.5'))), '0.005');
  });
}
