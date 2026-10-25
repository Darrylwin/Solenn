import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_strategy.dart';

/// Swaps two adjacent significant digits, so that 144 reads 414.
///
/// The magnitude is preserved: a swap that would put a zero in front is never
/// chosen.
class DigitShuffle implements SabotageStrategy {
  /// Creates the strategy.
  const DigitShuffle();

  @override
  SabotageKind get kind => SabotageKind.digitShuffle;

  @override
  Decimal? apply(SabotageContext context) {
    final truth = context.displayedTruth;
    if (isZero(truth)) return null;

    final value = decimalDigitsOf(truth);
    final digits = value.digits;

    final swaps = <int>[
      for (var at = 0; at < digits.length - 1; at++)
        if (digits[at] != digits[at + 1] && !(at == 0 && digits[1] == '0')) at,
    ];
    if (swaps.isEmpty) return null;

    final at = swaps[context.random.nextInt(swaps.length)];
    final swapped =
        '${digits.substring(0, at)}${digits[at + 1]}${digits[at]}'
        '${digits.substring(at + 2)}';

    return decimalFromDigits(
      (negative: value.negative, digits: swapped, exponent: value.exponent),
    );
  }
}
