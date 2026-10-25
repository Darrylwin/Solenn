import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

/// Computes the exact value of an [Expression].
///
/// Every operation is exact, then rounded to 15 significant digits (half away
/// from zero). The result is the *truth*: sabotage happens afterwards, in a
/// separate step.
class ExpressionEvaluator {
  /// Creates an evaluator. It holds no state.
  const ExpressionEvaluator();

  /// Evaluates [expression].
  EvaluationResult evaluate(Expression expression) {
    return switch (expression) {
      Literal(:final text) => EvaluationSuccess(Decimal.parse(text)),
      Percent(:final operand) => _evaluatePercent(operand),
      Binary(:final operation, :final left, :final right) => _evaluateBinary(
        operation,
        left,
        right,
      ),
    };
  }

  EvaluationResult _evaluatePercent(Expression operand) {
    final value = evaluate(operand);
    if (value is! EvaluationSuccess) return value;
    return _finish(percentValue(value.value));
  }

  EvaluationResult _evaluateBinary(
    ArithmeticOperator operation,
    Expression leftExpression,
    Expression rightExpression,
  ) {
    final left = evaluate(leftExpression);
    if (left is! EvaluationSuccess) return left;
    final right = evaluate(rightExpression);
    if (right is! EvaluationSuccess) return right;
    return _apply(operation, left.value, right.value);
  }

  EvaluationResult _apply(
    ArithmeticOperator operation,
    Decimal left,
    Decimal right,
  ) {
    final exact = switch (operation) {
      ArithmeticOperator.add => left + right,
      ArithmeticOperator.subtract => left - right,
      ArithmeticOperator.multiply => left * right,
      ArithmeticOperator.divide => divideDecimal(left, right),
    };

    if (exact == null) {
      return const EvaluationFailure(EvaluationFailureKind.divisionByZero);
    }
    // A nonzero dividend whose quotient vanished lies below the smallest
    // representable result.
    final vanished =
        operation == ArithmeticOperator.divide &&
        isZero(exact) &&
        !isZero(left);
    if (vanished) {
      return const EvaluationFailure(EvaluationFailureKind.overflow);
    }
    return _finish(exact);
  }

  EvaluationResult _finish(Decimal exact) {
    final rounded = roundToSignificantDigits(exact);
    if (isOutOfRange(rounded)) {
      return const EvaluationFailure(EvaluationFailureKind.overflow);
    }
    return EvaluationSuccess(rounded);
  }
}
