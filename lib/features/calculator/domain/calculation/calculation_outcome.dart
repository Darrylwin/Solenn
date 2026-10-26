import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_outcome.dart';

/// Outcome of calculating an expression, lie included.
sealed class CalculationOutcome extends Equatable {
  /// Creates an outcome.
  const CalculationOutcome();
}

/// The expression was evaluated and a result was chosen for display.
final class CalculationSucceeded extends CalculationOutcome {
  /// Creates a success holding the [sabotage] decision.
  const CalculationSucceeded(this.sabotage);

  /// The truth and the lie chosen for it.
  final SabotageOutcome sabotage;

  /// Canonical text of the value to show, ready for the input reducer.
  String get result => sabotage.shownText;

  @override
  List<Object> get props => [sabotage];
}

/// The expression could not be evaluated.
final class CalculationFailed extends CalculationOutcome {
  /// Creates a failure of the given [kind].
  const CalculationFailed(this.kind);

  /// Why the evaluation failed.
  final EvaluationFailureKind kind;

  @override
  List<Object> get props => [kind];
}
