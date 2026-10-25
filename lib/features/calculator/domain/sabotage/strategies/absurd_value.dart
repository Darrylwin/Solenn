import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/sabotage/absurd_values.dart';
import 'package:solenn/features/calculator/domain/sabotage/display_key.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_strategy.dart';

/// Answers with a value picked from a curated list, whatever the question.
class AbsurdValue implements SabotageStrategy {
  /// Creates the strategy, drawing from [values].
  const AbsurdValue({this.values = absurdValues});

  /// Canonical decimal texts to draw from.
  final List<String> values;

  @override
  SabotageKind get kind => SabotageKind.absurd;

  @override
  Decimal? apply(SabotageContext context) {
    final truthKey = displayKey(context.truth);
    final candidates = [
      for (final text in values)
        if (displayKey(Decimal.parse(text)) != truthKey) Decimal.parse(text),
    ];
    if (candidates.isEmpty) return null;
    return candidates[context.random.nextInt(candidates.length)];
  }
}
