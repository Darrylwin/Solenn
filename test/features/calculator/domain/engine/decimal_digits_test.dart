import 'package:flutter_test/flutter_test.dart' hide isNegative;
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';

import '../../../../helpers/sabotage_fixtures.dart';

void main() {
  group('decimalDigitsOf', () {
    final _ =
        {
          '24220': (negative: false, digits: '24220', exponent: 4),
          '-12.5': (negative: true, digits: '125', exponent: 1),
          '0.0333': (negative: false, digits: '333', exponent: -2),
          '100': (negative: false, digits: '100', exponent: 2),
          '0.5': (negative: false, digits: '5', exponent: -1),
          '1': (negative: false, digits: '1', exponent: 0),
          '123.456': (negative: false, digits: '123456', exponent: 2),
        }..forEach((text, expected) {
          test('$text should read $expected', () {
            expect(decimalDigitsOf(decimal(text)), expected);
          });
        });

    test('should ignore trailing zeros of a fraction', () {
      expect(decimalDigitsOf(decimal('1.500')).digits, '15');
    });
  });

  group('decimalFromDigits', () {
    test('should append zeros when the magnitude exceeds the digits', () {
      expect(
        canonicalText(
          decimalFromDigits((negative: false, digits: '12', exponent: 4)),
        ),
        '12000',
      );
    });

    test('should place the separator inside the digits', () {
      expect(
        canonicalText(
          decimalFromDigits((negative: false, digits: '125', exponent: 1)),
        ),
        '12.5',
      );
    });

    test('should prepend zeros for a small magnitude', () {
      expect(
        canonicalText(
          decimalFromDigits((negative: false, digits: '5', exponent: -4)),
        ),
        '0.0005',
      );
    });

    test('should keep the sign', () {
      expect(
        canonicalText(
          decimalFromDigits((negative: true, digits: '7', exponent: 0)),
        ),
        '-7',
      );
    });

    test('should invert decimalDigitsOf', () {
      for (final text in [
        '24220',
        '-12.5',
        '0.0333',
        '100',
        '0.5',
        '123.456',
        '1000000',
        '-0.000123',
      ]) {
        final value = decimal(text);

        expect(
          canonicalText(decimalFromDigits(decimalDigitsOf(value))),
          canonicalText(value),
          reason: text,
        );
      }
    });
  });

  group('leadingExponent', () {
    test('should be the power of ten of the first digit', () {
      expect(leadingExponent(decimal('24220')), 4);
      expect(leadingExponent(decimal('1')), 0);
      expect(leadingExponent(decimal('9.99')), 0);
      expect(leadingExponent(decimal('0.0333')), -2);
    });
  });

  group('roundToPowerOfTen', () {
    final _ =
        {
          ('24820', 3): '25000',
          ('24499', 3): '24000',
          ('8.5', 1): '10',
          ('-8.5', 1): '-10',
          ('25', 1): '30',
          ('24', 1): '20',
          ('5', 1): '10',
          ('1234567', 3): '1235000',
          ('1000', 3): '1000',
          ('999', 3): '1000',
          ('0.333', 1): '0',
          ('340', 2): '300',
        }..forEach((input, expected) {
          test('${input.$1} to 10^${input.$2} should read $expected', () {
            expect(
              canonicalText(roundToPowerOfTen(decimal(input.$1), input.$2)),
              expected,
            );
          });
        });
  });

  group('isNegative', () {
    test('should only be true below zero', () {
      expect(isNegative(decimal('-1')), isTrue);
      expect(isNegative(decimal('0')), isFalse);
      expect(isNegative(decimal('1')), isFalse);
    });
  });
}
