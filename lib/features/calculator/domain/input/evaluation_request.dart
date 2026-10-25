import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/input/repeat_operation.dart';

/// A complete expression that the reducer wants evaluated.
///
/// Tokens alternate between operands and operators, start and end with an
/// operand, and contain either an operator or a percent operand.
class EvaluationRequest extends Equatable {
  /// Creates a request for [tokens].
  const EvaluationRequest({required this.tokens});

  /// The expression, in reading order.
  final List<InputToken> tokens;

  /// The operation a further `=` repeats: the last operator and its right
  /// operand. `null` when the expression has no operator (a lone percent).
  RepeatOperation? get repeatOperation => switch (tokens) {
    [..., OperatorToken(:final value), final NumberToken operand] =>
      RepeatOperation(operation: value, operand: operand),
    _ => null,
  };

  @override
  List<Object> get props => [tokens];
}
