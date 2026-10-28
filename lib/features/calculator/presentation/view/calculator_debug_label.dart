import 'package:flutter/foundation.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/formatting/calculator_display_formatter.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_state.dart';

const String _separator = ' \u00B7 ';

/// The developer line shown over the display: the number of the calculation,
/// the strategy that lied, and the truth (contract S8).
///
/// It is `null` in a release build, where [enabled] is false. As the check is
/// a compile-time constant, the compiler removes the overlay from release
/// builds. It also stays `null` until a result is displayed, so the line never
/// outlives the result it describes.
String? calculatorDebugLabel(
  CalculatorState state,
  CalculatorDisplayFormatter formatter, {
  bool enabled = kDebugMode,
}) {
  final outcome = state.lastOutcome;
  if (!enabled ||
      outcome == null ||
      state.input.phase != InputPhase.evaluated) {
    return null;
  }

  final truth = formatter.formatNumber(canonicalText(outcome.truth));
  return [
    '#${state.committedCount}',
    outcome.kind.name,
    'truth $truth',
  ].join(_separator);
}
