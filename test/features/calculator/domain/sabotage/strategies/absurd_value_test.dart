import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/formatting/number_formatter.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/absurd_values.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/absurd_value.dart';

import '../../../../../helpers/sabotage_fixtures.dart';

void main() {
  const strategy = AbsurdValue();

  test('should be the absurd kind', () {
    expect(strategy.kind, SabotageKind.absurd);
  });

  group('the curated list', () {
    test('should hold at least eight values, 42 among them', () {
      expect(absurdValues.length, greaterThanOrEqualTo(8));
      expect(absurdValues, contains('42'));
    });

    test('should have no duplicate', () {
      expect(absurdValues.toSet().length, absurdValues.length);
    });

    test('should only hold values the display can show', () {
      for (final text in absurdValues) {
        final value = decimal(text);

        expect(canonicalText(value), text);
        expect(
          decimalDigitsOf(value).digits.length,
          lessThanOrEqualTo(displayDigits),
          reason: text,
        );
      }
    });
  });

  test('should answer a value of the list', () {
    final expression = binary(ArithmeticOperator.add, '10', '5');

    for (var seed = 0; seed < 100; seed++) {
      final shown = strategy.apply(contextFor(expression, seed: seed))!;

      expect(absurdValues, contains(canonicalText(shown)));
    }
  });

  test('should never answer the truth', () {
    final expression = binary(ArithmeticOperator.add, '40', '2');

    for (var seed = 0; seed < 200; seed++) {
      final shown = strategy.apply(contextFor(expression, seed: seed))!;

      expect(canonicalText(shown), isNot('42'));
    }
  });

  test('should give up when every value is the truth', () {
    const only42 = AbsurdValue(values: ['42']);

    expect(
      only42.apply(contextFor(binary(ArithmeticOperator.add, '40', '2'))),
      isNull,
    );
  });

  test('should draw from every value over many draws', () {
    final expression = binary(ArithmeticOperator.add, '10', '5');
    final drawn = {
      for (var seed = 0; seed < 500; seed++)
        canonicalText(strategy.apply(contextFor(expression, seed: seed))!),
    };

    expect(drawn, absurdValues.toSet());
  });
}
