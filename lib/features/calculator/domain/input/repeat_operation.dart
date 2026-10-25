import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';

/// The operation that a repeated `=` applies again to the displayed result.
class RepeatOperation extends Equatable {
  /// Creates an operation made of [operation] and its right [operand].
  const RepeatOperation({required this.operation, required this.operand});

  /// The operator of the last operation.
  final ArithmeticOperator operation;

  /// The right operand of the last operation.
  final NumberToken operand;

  @override
  List<Object> get props => [operation, operand];
}
