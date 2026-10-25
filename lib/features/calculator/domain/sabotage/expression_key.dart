import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';

/// A canonical text for [expression], used to give the same expression the
/// same lie for a whole launch.
///
/// Numbers are compared by value (`1.50` is `1.5`), but operand order is
/// preserved: `2 + 3` and `3 + 2` are different expressions, typed
/// differently, so they may lie differently.
String expressionKey(Expression expression) => switch (expression) {
  Literal(:final text) => canonicalText(Decimal.parse(text)),
  Percent(:final operand) => '%(${expressionKey(operand)})',
  Binary(:final operation, :final left, :final right) =>
    '(${operation.name} ${expressionKey(left)} ${expressionKey(right)})',
};
