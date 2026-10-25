import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/rounding_abuse.dart';

import '../../../../../helpers/sabotage_fixtures.dart';

const RoundingAbuse _strategy = RoundingAbuse();

String? _result(Expression expression) {
  final shown = _strategy.apply(contextFor(expression));
  return shown == null ? null : canonicalText(shown);
}

void main() {
  test('should be the roundingAbuse kind', () {
    expect(_strategy.kind, SabotageKind.roundingAbuse);
  });

  group('should round by magnitude', () {
    final _ =
        {
          '8.5': (binary(ArithmeticOperator.add, '7.3', '1.2'), '10'),
          '25': (binary(ArithmeticOperator.add, '20', '5'), '30'),
          '340': (binary(ArithmeticOperator.multiply, '34', '10'), '300'),
          '24820': (binary(ArithmeticOperator.add, '24000', '820'), '25000'),
          '1234567': (
            binary(ArithmeticOperator.add, '1234500', '67'),
            '1235000',
          ),
          '-8.5': (binary(ArithmeticOperator.subtract, '0', '8.5'), '-10'),
          '0.333...': (binary(ArithmeticOperator.divide, '1', '3'), '0'),
        }..forEach((name, testCase) {
          test('$name should read ${testCase.$2}', () {
            expect(_result(testCase.$1), testCase.$2);
          });
        });
  });

  group('should give up', () {
    test('on a number that is already round', () {
      expect(_result(binary(ArithmeticOperator.multiply, '10', '100')), isNull);
      expect(_result(binary(ArithmeticOperator.add, '5', '5')), isNull);
    });

    test('on zero', () {
      expect(_result(binary(ArithmeticOperator.subtract, '5', '5')), isNull);
    });
  });
}
