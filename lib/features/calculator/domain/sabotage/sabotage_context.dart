import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/engine/expression_evaluator.dart';
import 'package:solenn/features/calculator/domain/formatting/number_formatter.dart';

/// Everything a strategy may look at to invent a wrong result.
class SabotageContext {
  /// Creates a context.
  const SabotageContext({
    required this.expression,
    required this.truth,
    required this.random,
    required this.evaluator,
  });

  /// The expression that was evaluated.
  final Expression expression;

  /// Its exact result.
  final Decimal truth;

  /// The only source of randomness a strategy may use.
  final Random random;

  /// Evaluates sub-expressions, for strategies that recompute.
  final ExpressionEvaluator evaluator;

  /// [truth] as the user would read it, rounded to the digits of the display.
  ///
  /// Strategies lie about this value: a lie that differs from it only beyond
  /// the ninth digit would be invisible.
  Decimal get displayedTruth =>
      roundToSignificantDigits(truth, digits: displayDigits);
}
