import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';

const List<InputToken> _pendingAdd = [
  NumberToken('5'),
  OperatorToken(ArithmeticOperator.add),
];

void main() {
  group('displayedNumber', () {
    test('should be zero for an empty input', () {
      expect(
        const CalculatorInputState().displayedNumber,
        const NumberToken('0'),
      );
    });

    test('should be the entry being typed', () {
      expect(
        const CalculatorInputState(entry: '12.').displayedNumber,
        const NumberToken('12.'),
      );
    });

    test('should carry the percent sign of the entry', () {
      const state = CalculatorInputState(entry: '5', entryIsPercent: true);

      expect(state.displayedNumber, const NumberToken('5', isPercent: true));
    });

    test('should be the operand before a pending operator', () {
      expect(
        const CalculatorInputState(tokens: _pendingAdd).displayedNumber,
        const NumberToken('5'),
      );
    });

    test('should be the result once evaluated', () {
      const state = CalculatorInputState(
        tokens: [
          NumberToken('3'),
          OperatorToken(ArithmeticOperator.add),
          NumberToken('4'),
        ],
        phase: InputPhase.evaluated,
        result: '7',
      );

      expect(state.displayedNumber, const NumberToken('7'));
    });

    test('should be zero after an error', () {
      const state = CalculatorInputState(phase: InputPhase.error);

      expect(state.displayedNumber, const NumberToken('0'));
    });
  });

  group('pendingOperator', () {
    test('should be the operator awaiting its right operand', () {
      expect(
        const CalculatorInputState(tokens: _pendingAdd).pendingOperator,
        ArithmeticOperator.add,
      );
    });

    test('should be null while an operand is being typed', () {
      const state = CalculatorInputState(tokens: _pendingAdd, entry: '3');

      expect(state.pendingOperator, isNull);
    });

    test('should be null for an empty input', () {
      expect(const CalculatorInputState().pendingOperator, isNull);
    });

    test('should be null once evaluated', () {
      const state = CalculatorInputState(
        tokens: _pendingAdd,
        phase: InputPhase.evaluated,
        result: '10',
      );

      expect(state.pendingOperator, isNull);
    });
  });

  test('should report an error only in the error phase', () {
    expect(const CalculatorInputState(phase: InputPhase.error).isError, isTrue);
    expect(const CalculatorInputState().isError, isFalse);
  });

  test('should compare states by value', () {
    expect(
      const CalculatorInputState(entry: '5'),
      const CalculatorInputState(entry: '5'),
    );
    expect(
      const CalculatorInputState(entry: '5'),
      isNot(const CalculatorInputState(entry: '6')),
    );
  });
}
