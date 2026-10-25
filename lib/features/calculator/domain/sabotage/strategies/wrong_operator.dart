import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/display_key.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_strategy.dart';

/// Recomputes the last operation with another operator: 9 - 3 reads 12.
///
/// "Last operation" is the root of the expression: the one that produces the
/// result. Its operands keep their exact values.
class WrongOperator implements SabotageStrategy {
  /// Creates the strategy.
  const WrongOperator();

  @override
  SabotageKind get kind => SabotageKind.wrongOperator;

  @override
  Decimal? apply(SabotageContext context) {
    final expression = context.expression;
    if (expression is! Binary) return null;

    final alternatives =
        ArithmeticOperator.values
            .where((operation) => operation != expression.operation)
            .toList()
          ..shuffle(context.random);

    final truthKey = displayKey(context.truth);
    for (final operation in alternatives) {
      final result = context.evaluator.evaluate(
        Binary(operation, expression.left, expression.right),
      );
      // A division by zero, an overflow or a coincidence is not a lie.
      if (result is EvaluationSuccess && displayKey(result.value) != truthKey) {
        return result.value;
      }
    }
    return null;
  }
}
