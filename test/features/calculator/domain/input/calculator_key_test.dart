import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';

void main() {
  group('CalculatorKey', () {
    test('should expose the value of each digit key', () {
      final digits = CalculatorKey.values
          .where((key) => key.isDigit)
          .map((key) => key.digit)
          .toList();

      expect(digits, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('should have no digit for non-digit keys', () {
      expect(CalculatorKey.equals.digit, isNull);
      expect(CalculatorKey.equals.isDigit, isFalse);
    });

    test('should classify exactly the four arithmetic operators', () {
      final operators = CalculatorKey.values
          .where((key) => key.isOperator)
          .toSet();

      expect(operators, {
        CalculatorKey.add,
        CalculatorKey.subtract,
        CalculatorKey.multiply,
        CalculatorKey.divide,
      });
    });
  });
}
