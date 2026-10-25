import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';

/// Outcome of pressing a key.
sealed class ReductionResult extends Equatable {
  /// Creates a result.
  const ReductionResult();
}

/// The key changed (or left unchanged) the input state.
final class InputUpdated extends ReductionResult {
  /// Creates an update to [state].
  const InputUpdated(this.state);

  /// The state after the key.
  final CalculatorInputState state;

  @override
  List<Object> get props => [state];
}

/// The key asks for an expression to be evaluated.
///
/// The caller evaluates [request] and reports the outcome with
/// `CalculatorInputReducer.complete` or `completeWithError`.
final class EvaluationRequested extends ReductionResult {
  /// Creates a request.
  const EvaluationRequested(this.request);

  /// The expression to evaluate.
  final EvaluationRequest request;

  @override
  List<Object> get props => [request];
}
