import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';

/// Why an evaluation failed.
enum EvaluationFailureKind {
  /// A division by zero.
  divisionByZero,

  /// A result beyond the representable range, large or small.
  overflow,
}

/// Outcome of evaluating an expression.
sealed class EvaluationResult extends Equatable {
  /// Creates a result.
  const EvaluationResult();
}

/// A successful evaluation. [value] is the truth, before any sabotage.
final class EvaluationSuccess extends EvaluationResult {
  /// Creates a success holding [value].
  const EvaluationSuccess(this.value);

  /// The exact result, rounded to the significant digits of the calculator.
  final Decimal value;

  /// Canonical decimal text of [value].
  String get text => canonicalText(value);

  @override
  List<Object> get props => [value];
}

/// A failed evaluation.
final class EvaluationFailure extends EvaluationResult {
  /// Creates a failure of the given [kind].
  const EvaluationFailure(this.kind);

  /// The reason of the failure.
  final EvaluationFailureKind kind;

  @override
  List<Object> get props => [kind];
}
