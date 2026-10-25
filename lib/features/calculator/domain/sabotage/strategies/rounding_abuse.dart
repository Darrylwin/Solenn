import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_strategy.dart';

/// Rounds to the nearest 10, 100 or 1000, depending on the magnitude: 8.5
/// reads 10, 24,820 reads 25,000.
class RoundingAbuse implements SabotageStrategy {
  /// Creates the strategy.
  const RoundingAbuse();

  static const int _finestPower = 1;
  static const int _coarsestPower = 3;

  @override
  SabotageKind get kind => SabotageKind.roundingAbuse;

  @override
  Decimal? apply(SabotageContext context) {
    final truth = context.displayedTruth;
    if (isZero(truth)) return null;

    final power = math.min(
      _coarsestPower,
      math.max(_finestPower, leadingExponent(truth)),
    );
    final rounded = roundToPowerOfTen(truth, power);

    // A number that is already round has nothing to abuse.
    return rounded.compareTo(truth) == 0 ? null : rounded;
  }
}
