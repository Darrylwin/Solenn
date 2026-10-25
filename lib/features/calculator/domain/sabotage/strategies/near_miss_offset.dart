import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/sabotage/plausibility.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_strategy.dart';

/// Shifts one of the three most significant digits by one to three units.
///
/// It applies to every input, so the engine uses it as its fallback.
class NearMissOffset implements SabotageStrategy {
  /// Creates the strategy.
  const NearMissOffset();

  static const int _shiftablePositions = 3;
  static const int _maxStep = 3;

  @override
  SabotageKind get kind => SabotageKind.nearMissOffset;

  @override
  Decimal? apply(SabotageContext context) => offset(context);

  /// A plausible wrong value for [context]. Unlike other strategies this one
  /// never gives up.
  Decimal offset(SabotageContext context) {
    final random = context.random;
    final truth = context.displayedTruth;

    if (isZero(truth)) {
      return Decimal.parse('${1 + random.nextInt(_maxStep)}');
    }

    final digits = decimalDigitsOf(truth);
    final reach = math.min(_shiftablePositions, digits.digits.length);
    final position = digits.exponent - random.nextInt(reach);
    final step = 1 + random.nextInt(_maxStep);
    final delta = decimalFromDigits(
      (negative: false, digits: '$step', exponent: position),
    );
    final subtractFirst = random.nextBool();

    // One direction always stays plausible: adding keeps the sign and the
    // magnitude, except at the very top of the range, where subtracting does.
    final first = subtractFirst ? truth - delta : truth + delta;
    if (isPlausible(shown: first, truth: truth)) return first;

    final second = subtractFirst ? truth + delta : truth - delta;
    if (isPlausible(shown: second, truth: truth)) return second;

    throw StateError('No plausible offset of $truth by $delta.');
  }
}
