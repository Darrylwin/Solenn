import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

/// An element of the expression being built: a number or an operator.
sealed class InputToken extends Equatable {
  /// Creates a token.
  const InputToken();
}

/// An operand.
///
/// [text] is a canonical decimal: ASCII digits, an optional leading `-` and an
/// optional `.` separator, whatever the device locale. Showing it in the
/// locale's format is a presentation concern.
final class NumberToken extends InputToken {
  /// Creates an operand. [isPercent] marks a trailing percent sign.
  const NumberToken(this.text, {this.isPercent = false});

  /// Canonical decimal text of the operand.
  final String text;

  /// Whether the operand carries a percent sign. Its meaning depends on the
  /// surrounding operators and is resolved by the evaluator.
  final bool isPercent;

  @override
  List<Object> get props => [text, isPercent];
}

/// A binary operator between two operands.
final class OperatorToken extends InputToken {
  /// Creates an operator token.
  const OperatorToken(this.value);

  /// The operator.
  final ArithmeticOperator value;

  @override
  List<Object> get props => [value];
}
