import 'package:solenn/features/calculator/domain/calculation/calculation_outcome.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/engine/expression_evaluator.dart';
import 'package:solenn/features/calculator/domain/engine/expression_parser.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';

/// Parses, evaluates and sabotages an expression.
///
/// The truth is always computed first; the lie is a separate, later step
/// (constraint C4). Errors are never sabotaged.
class CalculationPipeline {
  /// Creates a pipeline that lies through [sabotageEngine].
  const CalculationPipeline({
    required SabotageEngine sabotageEngine,
    ExpressionParser parser = const ExpressionParser(),
    ExpressionEvaluator evaluator = const ExpressionEvaluator(),
  }) : _sabotageEngine = sabotageEngine,
       _parser = parser,
       _evaluator = evaluator;

  final SabotageEngine _sabotageEngine;
  final ExpressionParser _parser;
  final ExpressionEvaluator _evaluator;

  /// Calculates [request].
  ///
  /// [calculationIndex] is the number this calculation would have among the
  /// successful ones of the launch (1 for the first). It only matters on
  /// success: a failure does not use up an index.
  CalculationOutcome calculate(
    EvaluationRequest request, {
    required int calculationIndex,
  }) {
    final expression = _parser.parse(request.tokens);

    return switch (_evaluator.evaluate(expression)) {
      EvaluationSuccess(:final value) => CalculationSucceeded(
        _sabotageEngine.sabotage(
          expression: expression,
          truth: value,
          calculationIndex: calculationIndex,
        ),
      ),
      EvaluationFailure(:final kind) => CalculationFailed(kind),
    };
  }
}
