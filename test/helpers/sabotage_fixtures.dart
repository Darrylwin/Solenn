import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/engine/expression_evaluator.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';

const ExpressionEvaluator evaluator = ExpressionEvaluator();

Decimal decimal(String text) => Decimal.parse(text);

Expression binary(ArithmeticOperator operation, String left, String right) =>
    Binary(operation, Literal(left), Literal(right));

/// The exact value of [expression], which must evaluate.
Decimal truthOf(Expression expression) {
  final result = evaluator.evaluate(expression);
  if (result is! EvaluationSuccess) {
    throw StateError('$expression does not evaluate.');
  }
  return result.value;
}

SabotageContext contextFor(Expression expression, {int seed = 0}) =>
    SabotageContext(
      expression: expression,
      truth: truthOf(expression),
      random: Random(seed),
      evaluator: evaluator,
    );

typedef Sample = ({Expression expression, Decimal truth});

String _randomNumber(Random random) {
  if (random.nextInt(12) == 0) return '0';

  final integer = StringBuffer('${1 + random.nextInt(9)}');
  for (var i = random.nextInt(6); i > 0; i--) {
    integer.write(random.nextInt(10));
  }
  var text = integer.toString();
  if (random.nextBool()) {
    final fraction = StringBuffer();
    for (var i = 1 + random.nextInt(3); i > 0; i--) {
      fraction.write(random.nextInt(10));
    }
    text = '$text.$fraction';
  }
  return random.nextInt(5) == 0 ? '-$text' : text;
}

Expression randomExpression(Random random, {int depth = 3}) {
  if (depth == 0 || random.nextInt(3) == 0) {
    final literal = Literal(_randomNumber(random));
    return random.nextInt(8) == 0 ? Percent(literal) : literal;
  }
  return Binary(
    ArithmeticOperator.values[random.nextInt(ArithmeticOperator.values.length)],
    randomExpression(random, depth: depth - 1),
    randomExpression(random, depth: depth - 1),
  );
}

/// A random expression with its truth, or `null` when it does not evaluate
/// (a division by zero).
Sample? randomSample(Random random) {
  final expression = randomExpression(random);
  final result = evaluator.evaluate(expression);
  if (result is! EvaluationSuccess) return null;
  return (expression: expression, truth: result.value);
}

/// A distinct, ordinary expression for each [index]: 3-digit and up results
/// with varied digits, to which every strategy can apply.
Sample familySample(int index) {
  final expression = binary(
    ArithmeticOperator.subtract,
    '${1000 + 37 * index}',
    '7',
  );
  return (expression: expression, truth: truthOf(expression));
}
