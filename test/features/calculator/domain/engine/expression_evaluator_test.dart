import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/engine/expression_evaluator.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

const ExpressionEvaluator _evaluator = ExpressionEvaluator();

const Expression _one = Literal('1');
const Expression _zero = Literal('0');
const Expression _divisionByZero = Binary(
  ArithmeticOperator.divide,
  _one,
  _zero,
);

String _text(Expression expression) {
  final result = _evaluator.evaluate(expression);
  expect(result, isA<EvaluationSuccess>());
  return (result as EvaluationSuccess).text;
}

EvaluationFailureKind _failure(Expression expression) {
  final result = _evaluator.evaluate(expression);
  expect(result, isA<EvaluationFailure>());
  return (result as EvaluationFailure).kind;
}

Expression _binary(ArithmeticOperator operation, String left, String right) =>
    Binary(operation, Literal(left), Literal(right));

void main() {
  group('operations', () {
    test('should evaluate a literal', () {
      expect(_text(const Literal('-12.5')), '-12.5');
    });

    test('should add exactly', () {
      expect(_text(_binary(ArithmeticOperator.add, '0.1', '0.2')), '0.3');
    });

    test('should subtract', () {
      expect(_text(_binary(ArithmeticOperator.subtract, '1', '3')), '-2');
    });

    test('should multiply', () {
      expect(_text(_binary(ArithmeticOperator.multiply, '1.5', '2')), '3');
    });

    test('should divide exactly when the quotient is finite', () {
      expect(_text(_binary(ArithmeticOperator.divide, '1', '4')), '0.25');
    });

    test('should round a repeating quotient to 15 significant digits', () {
      expect(
        _text(_binary(ArithmeticOperator.divide, '2', '3')),
        '0.666666666666667',
      );
    });

    test('should round every operation, not only the last', () {
      const expression = Binary(
        ArithmeticOperator.multiply,
        Binary(ArithmeticOperator.divide, _one, Literal('3')),
        Literal('3'),
      );

      expect(_text(expression), '0.999999999999999');
    });

    test('should evaluate nested expressions', () {
      const expression = Binary(
        ArithmeticOperator.add,
        Literal('2'),
        Binary(ArithmeticOperator.multiply, Literal('3'), Literal('4')),
      );

      expect(_text(expression), '14');
    });
  });

  group('percent', () {
    test('should be a hundredth', () {
      expect(_text(const Percent(Literal('50'))), '0.5');
    });

    test('should propagate a failure of its operand', () {
      expect(_failure(const Percent(_divisionByZero)), isNotNull);
    });
  });

  group('failures', () {
    test('should report a division by zero', () {
      expect(
        _failure(_divisionByZero),
        EvaluationFailureKind.divisionByZero,
      );
      expect(
        _failure(_binary(ArithmeticOperator.divide, '0', '0')),
        EvaluationFailureKind.divisionByZero,
      );
    });

    test('should propagate a failure of the left operand', () {
      const expression = Binary(
        ArithmeticOperator.add,
        _divisionByZero,
        _one,
      );

      expect(_failure(expression), EvaluationFailureKind.divisionByZero);
    });

    test('should propagate a failure of the right operand', () {
      const expression = Binary(
        ArithmeticOperator.add,
        _one,
        _divisionByZero,
      );

      expect(_failure(expression), EvaluationFailureKind.divisionByZero);
    });

    test('should report a result above the range', () {
      final huge = '1${'0' * 99}';

      expect(
        _text(_binary(ArithmeticOperator.multiply, huge, '1')),
        huge,
      );
      expect(
        _failure(_binary(ArithmeticOperator.multiply, huge, '10')),
        EvaluationFailureKind.overflow,
      );
    });

    test('should report a nonzero result below the range', () {
      final tiny = '0.${'0' * 98}1';

      expect(
        _failure(_binary(ArithmeticOperator.divide, tiny, '10')),
        EvaluationFailureKind.overflow,
      );
    });

    test('should report a quotient that vanishes entirely', () {
      final tiny = '0.${'0' * 98}1';
      final huge = '1${'0' * 99}';

      expect(
        _failure(_binary(ArithmeticOperator.divide, tiny, huge)),
        EvaluationFailureKind.overflow,
      );
    });

    test('should not report a zero result as out of range', () {
      expect(_text(_binary(ArithmeticOperator.divide, '0', '5')), '0');
    });
  });

  test('should compare results by value', () {
    expect(
      _evaluator.evaluate(const Literal('2')),
      _evaluator.evaluate(const Literal('2.0')),
    );
    expect(
      const EvaluationFailure(EvaluationFailureKind.overflow),
      const EvaluationFailure(EvaluationFailureKind.overflow),
    );
  });
}
