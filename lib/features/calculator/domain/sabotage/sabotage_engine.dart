import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/engine/expression_evaluator.dart';
import 'package:solenn/features/calculator/domain/sabotage/display_key.dart';
import 'package:solenn/features/calculator/domain/sabotage/expression_key.dart';
import 'package:solenn/features/calculator/domain/sabotage/plausibility.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_config.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_outcome.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_phase.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_strategy.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/absurd_value.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/digit_shuffle.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/near_miss_offset.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/rounding_abuse.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/wrong_operator.dart';

/// Turns the truth of a calculation into the lie the user sees.
///
/// For a given seed the engine is deterministic. Its only state is a memo that
/// gives an expression the same lie for the whole launch (contract S2): the
/// engine lives as long as the launch and is never persisted.
class SabotageEngine {
  /// Creates an engine drawing randomness from [random].
  ///
  /// [strategies] overrides the built-in ones; it must provide every kind.
  SabotageEngine({
    required Random random,
    this.config = SabotageConfig.standard,
    ExpressionEvaluator evaluator = const ExpressionEvaluator(),
    Map<SabotageKind, SabotageStrategy>? strategies,
  }) : assert(
         strategies == null ||
             SabotageKind.values.every(strategies.containsKey),
         'A strategy is required for every kind.',
       ),
       _random = random,
       _evaluator = evaluator,
       _strategies = strategies ?? _standardStrategies;

  static const Map<SabotageKind, SabotageStrategy> _standardStrategies = {
    SabotageKind.nearMissOffset: NearMissOffset(),
    SabotageKind.digitShuffle: DigitShuffle(),
    SabotageKind.roundingAbuse: RoundingAbuse(),
    SabotageKind.wrongOperator: WrongOperator(),
    SabotageKind.absurd: AbsurdValue(),
  };

  /// Phases and weights in use.
  final SabotageConfig config;

  final Random _random;
  final ExpressionEvaluator _evaluator;
  final Map<SabotageKind, SabotageStrategy> _strategies;
  final NearMissOffset _fallback = const NearMissOffset();
  final Map<String, SabotageOutcome> _remembered = {};

  /// The lie to show for [expression], whose exact result is [truth].
  ///
  /// [calculationIndex] counts the successful calculations of the launch,
  /// starting at 1, and decides how daring the lie may be.
  SabotageOutcome sabotage({
    required Expression expression,
    required Decimal truth,
    required int calculationIndex,
  }) {
    assert(calculationIndex >= 1, 'Calculation indexes start at 1.');

    return _remembered.putIfAbsent(
      expressionKey(expression),
      () => _choose(expression, truth, calculationIndex),
    );
  }

  SabotageOutcome _choose(
    Expression expression,
    Decimal truth,
    int calculationIndex,
  ) {
    final phase = config.phaseOf(calculationIndex);
    final context = SabotageContext(
      expression: expression,
      truth: truth,
      random: _random,
      evaluator: _evaluator,
    );

    // Weighted draws without replacement: a strategy that does not apply, or
    // whose answer is rejected, gives way to the next draw.
    final weights = Map.of(config.weightsOf(phase))
      ..removeWhere((_, weight) => weight <= 0);
    while (weights.isNotEmpty) {
      final kind = _draw(weights);
      weights.remove(kind);

      final shown = _accept(_strategies[kind]!.apply(context), context, phase);
      if (shown != null) {
        return SabotageOutcome(truth: truth, shown: shown, kind: kind);
      }
    }

    final shown = _accept(_fallback.offset(context), context, phase);
    if (shown == null) {
      throw StateError('The fallback rejected its own answer for $truth.');
    }
    return SabotageOutcome(
      truth: truth,
      shown: shown,
      kind: SabotageKind.nearMissOffset,
    );
  }

  SabotageKind _draw(Map<SabotageKind, int> weights) {
    final total = weights.values.fold(0, (sum, weight) => sum + weight);
    var ticket = _random.nextInt(total);
    for (final MapEntry(:key, :value) in weights.entries) {
      if (ticket < value) return key;
      ticket -= value;
    }
    return weights.keys.last;
  }

  /// [candidate] as it will be shown, or `null` when it breaks a contract.
  Decimal? _accept(
    Decimal? candidate,
    SabotageContext context,
    SabotagePhase phase,
  ) {
    if (candidate == null) return null;

    final shown = roundToSignificantDigits(candidate);
    if (isOutOfRange(shown)) return null;
    if (displayKey(shown) == displayKey(context.truth)) return null;

    final believable =
        phase != SabotagePhase.plausible ||
        isPlausible(shown: shown, truth: context.displayedTruth);
    return believable ? shown : null;
  }
}
