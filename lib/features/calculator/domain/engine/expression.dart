import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

/// A parsed arithmetic expression.
///
/// A negative number is a literal (`-5`), so there is no unary node: the sign
/// belongs to the operand the user typed.
sealed class Expression extends Equatable {
  /// Creates an expression.
  const Expression();
}

/// A number, as canonical decimal text.
final class Literal extends Expression {
  /// Creates a literal from its [text].
  const Literal(this.text);

  /// Canonical decimal text of the number.
  final String text;

  @override
  List<Object> get props => [text];
}

/// One hundredth of [operand].
///
/// The meaning of a percent sign that depends on an operand to its left
/// (`50 + 10%`) is made explicit by the parser, so this node never needs
/// context.
final class Percent extends Expression {
  /// Creates a percentage of [operand].
  const Percent(this.operand);

  /// The expression expressed as a percentage.
  final Expression operand;

  @override
  List<Object> get props => [operand];
}

/// A binary operation.
final class Binary extends Expression {
  /// Creates the operation `left operation right`.
  const Binary(this.operation, this.left, this.right);

  /// The operator.
  final ArithmeticOperator operation;

  /// The left operand.
  final Expression left;

  /// The right operand.
  final Expression right;

  @override
  List<Object> get props => [operation, left, right];
}
