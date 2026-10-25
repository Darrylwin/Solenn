import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';

void main() {
  group('ArithmeticOperator', () {
    test('should give multiplication and division the high precedence', () {
      final high = ArithmeticOperator.values
          .where((operator) => operator.hasHighPrecedence)
          .toSet();

      expect(high, {ArithmeticOperator.multiply, ArithmeticOperator.divide});
    });

    test('should map every operator to its key and back', () {
      for (final operator in ArithmeticOperator.values) {
        expect(operator.key.arithmeticOperator, operator);
      }
    });
  });

  group('CalculatorKey.arithmeticOperator', () {
    test('should be null for non-operator keys', () {
      final others = CalculatorKey.values.where((key) => !key.isOperator);

      for (final key in others) {
        expect(key.arithmeticOperator, isNull, reason: '$key');
      }
    });
  });
}
