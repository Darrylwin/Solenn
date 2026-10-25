import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart' hide isZero;
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/formatting/number_formatter.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/display_key.dart';
import 'package:solenn/features/calculator/domain/sabotage/plausibility.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_config.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_outcome.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_strategy.dart';

import '../../../../helpers/sabotage_fixtures.dart';

class _Fixed implements SabotageStrategy {
  _Fixed(this.kind, this.value);

  @override
  final SabotageKind kind;
  final Decimal? value;

  @override
  Decimal? apply(SabotageContext context) => value;
}

SabotageEngine _engineAnswering(Decimal? value, {int seed = 1}) =>
    SabotageEngine(
      random: Random(seed),
      strategies: {
        for (final kind in SabotageKind.values) kind: _Fixed(kind, value),
      },
    );

final _trailingZeroDigits = RegExp(r'0+$');

int _significantDigitCount(Decimal value) => isZero(value)
    ? 0
    : decimalDigitsOf(
        value,
      ).digits.replaceFirst(_trailingZeroDigits, '').length;

SabotageOutcome _outcome(
  SabotageEngine engine,
  Expression expression, {
  int index = 1,
}) => engine.sabotage(
  expression: expression,
  truth: truthOf(expression),
  calculationIndex: index,
);

void main() {
  final sample = binary(ArithmeticOperator.add, '100', '44');

  group('basics', () {
    test('should never show the truth', () {
      final engine = SabotageEngine(random: Random(1));

      final outcome = _outcome(engine, sample);

      expect(displayKey(outcome.shown), isNot(displayKey(outcome.truth)));
      expect(outcome.truth, decimal('144'));
    });

    test('should expose the shown value for the reducer', () {
      final engine = SabotageEngine(random: Random(1));

      expect(
        decimal(_outcome(engine, sample).shownText),
        _outcome(engine, sample).shown,
      );
    });

    test('should require a strategy for every kind', () {
      expect(
        () => SabotageEngine(
          random: Random(1),
          strategies: {
            SabotageKind.nearMissOffset: _Fixed(
              SabotageKind.nearMissOffset,
              null,
            ),
          },
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should reject a calculation index below one', () {
      final engine = SabotageEngine(random: Random(1));

      expect(
        () => _outcome(engine, sample, index: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('memoization (S2)', () {
    test('should give an expression the same lie for the whole launch', () {
      final engine = SabotageEngine(random: Random(1));

      final first = _outcome(engine, sample);
      final later = _outcome(engine, sample, index: 12);

      expect(later, first);
    });

    test('should recognize an expression typed with other trailing zeros', () {
      final engine = SabotageEngine(random: Random(1));

      final first = _outcome(
        engine,
        binary(ArithmeticOperator.add, '1.50', '1'),
      );
      final second = _outcome(
        engine,
        binary(ArithmeticOperator.add, '1.5', '1'),
      );

      expect(second, first);
    });

    test('should not consume randomness when answering from the memo', () {
      final engine = SabotageEngine(random: Random(1));
      final reference = SabotageEngine(random: Random(1));
      final other = binary(ArithmeticOperator.add, '300', '21');

      _outcome(engine, sample);
      _outcome(engine, sample);
      _outcome(engine, sample);
      _outcome(reference, sample);

      expect(_outcome(engine, other), _outcome(reference, other));
    });
  });

  group('determinism (S7)', () {
    List<SabotageOutcome> run(int seed) {
      final generator = Random(5);
      final engine = SabotageEngine(random: Random(seed));
      final outcomes = <SabotageOutcome>[];
      var index = 0;
      while (outcomes.length < 400) {
        final next = randomSample(generator);
        if (next == null) continue;
        index++;
        outcomes.add(
          engine.sabotage(
            expression: next.expression,
            truth: next.truth,
            calculationIndex: 1 + index % 15,
          ),
        );
      }
      return outcomes;
    }

    test('should give the same lies for the same seed', () {
      expect(run(11), run(11));
    });

    test('should give other lies for another seed', () {
      expect(run(11), isNot(run(12)));
    });
  });

  group('contracts over random expressions', () {
    test('S1 and S6: never the truth, always displayable', () {
      final generator = Random(2026);
      final engine = SabotageEngine(random: Random(7));
      var checked = 0;

      for (var attempt = 0; attempt < 50000 && checked < 10000; attempt++) {
        final next = randomSample(generator);
        if (next == null) continue;
        checked++;

        final outcome = engine.sabotage(
          expression: next.expression,
          truth: next.truth,
          calculationIndex: 1 + generator.nextInt(20),
        );

        final reason = '${next.expression} -> ${outcome.shown}';
        expect(
          displayKey(outcome.shown),
          isNot(displayKey(next.truth)),
          reason: reason,
        );
        expect(isOutOfRange(outcome.shown), isFalse, reason: reason);
        expect(
          _significantDigitCount(outcome.shown),
          lessThanOrEqualTo(significantDigits),
          reason: reason,
        );
      }

      expect(checked, 10000);
    });

    test('S3 and S4: plausible lies in the first phase', () {
      final generator = Random(2027);
      final engine = SabotageEngine(random: Random(8));
      var checked = 0;

      for (var attempt = 0; attempt < 50000 && checked < 5000; attempt++) {
        final next = randomSample(generator);
        if (next == null) continue;
        checked++;

        final outcome = engine.sabotage(
          expression: next.expression,
          truth: next.truth,
          calculationIndex: 1 + generator.nextInt(3),
        );

        expect(
          isPlausible(
            shown: outcome.shown,
            truth: roundToSignificantDigits(next.truth, digits: displayDigits),
          ),
          isTrue,
          reason: '${next.expression} -> ${outcome.shown}',
        );
        expect(
          outcome.kind,
          anyOf(SabotageKind.nearMissOffset, SabotageKind.digitShuffle),
        );
      }
    });

    test('S4: no absurd value before the ninth calculation', () {
      final generator = Random(2028);
      final engine = SabotageEngine(random: Random(9));
      var checked = 0;

      for (var attempt = 0; attempt < 50000 && checked < 5000; attempt++) {
        final next = randomSample(generator);
        if (next == null) continue;
        checked++;

        final outcome = engine.sabotage(
          expression: next.expression,
          truth: next.truth,
          calculationIndex: 1 + generator.nextInt(8),
        );

        expect(outcome.kind, isNot(SabotageKind.absurd));
      }
    });
  });

  group('edge cases (S5)', () {
    test('should handle zero, extremes and tiny values in every phase', () {
      final texts = [
        '0',
        '1',
        '-1',
        '123456789',
        '9${'0' * 99}',
        '1${'0' * 99}',
        '-9${'0' * 99}',
        '0.${'0' * 98}1',
        '-0.${'0' * 98}1',
      ];

      for (final text in texts) {
        for (final index in [1, 5, 9]) {
          for (var seed = 0; seed < 40; seed++) {
            final engine = SabotageEngine(random: Random(seed));
            final truth = decimal(text);

            final outcome = engine.sabotage(
              expression: Literal(text),
              truth: truth,
              calculationIndex: index,
            );

            final reason = '$text, index $index, seed $seed';
            expect(
              displayKey(outcome.shown),
              isNot(displayKey(truth)),
              reason: reason,
            );
            expect(isOutOfRange(outcome.shown), isFalse, reason: reason);
          }
        }
      }
    });

    test('should answer a small positive number for a zero truth at first', () {
      final zero = binary(ArithmeticOperator.subtract, '5', '5');

      for (var seed = 0; seed < 50; seed++) {
        final outcome = _outcome(SabotageEngine(random: Random(seed)), zero);

        expect(outcome.kind, SabotageKind.nearMissOffset);
        expect(['1', '2', '3'], contains(outcome.shownText));
      }
    });
  });

  group('escalation', () {
    Map<SabotageKind, int> kindsOver(int count, int index) {
      final engine = SabotageEngine(random: Random(2026));
      final counts = <SabotageKind, int>{};
      for (var i = 0; i < count; i++) {
        final next = familySample(i);
        final outcome = engine.sabotage(
          expression: next.expression,
          truth: next.truth,
          calculationIndex: index,
        );
        counts.update(outcome.kind, (n) => n + 1, ifAbsent: () => 1);
      }
      return counts;
    }

    test('should only shift or shuffle digits at first', () {
      expect(
        kindsOver(2000, 2).keys.toSet(),
        {SabotageKind.nearMissOffset, SabotageKind.digitShuffle},
      );
    });

    test('should add rounding and wrong operators, without absurd values', () {
      expect(
        kindsOver(2000, 5).keys.toSet(),
        {
          SabotageKind.nearMissOffset,
          SabotageKind.digitShuffle,
          SabotageKind.roundingAbuse,
          SabotageKind.wrongOperator,
        },
      );
    });

    test('should keep absurd values to about 15 percent when they appear', () {
      final counts = kindsOver(10000, 9);
      final absurd = counts[SabotageKind.absurd] ?? 0;

      expect(counts.keys.toSet(), SabotageKind.values.toSet());
      expect(absurd / 10000, inInclusiveRange(0.12, 0.18));
    });
  });

  group('rejected strategies', () {
    final truth144 = sample;

    test('should fall back when a strategy answers the truth', () {
      final engine = _engineAnswering(decimal('144'));

      final outcome = _outcome(engine, truth144);

      expect(outcome.kind, SabotageKind.nearMissOffset);
      expect(displayKey(outcome.shown), isNot('144'));
    });

    test('should fall back when no strategy applies', () {
      final outcome = _outcome(_engineAnswering(null), truth144);

      expect(outcome.kind, SabotageKind.nearMissOffset);
      expect(displayKey(outcome.shown), isNot('144'));
    });

    test('should fall back when an answer is out of range', () {
      final outcome = _outcome(
        _engineAnswering(decimal('1${'0' * 100}')),
        truth144,
        index: 5,
      );

      expect(outcome.kind, SabotageKind.nearMissOffset);
      expect(isOutOfRange(outcome.shown), isFalse);
    });

    test(
      'should refuse an implausible answer while lies must be plausible',
      () {
        final engine = _engineAnswering(decimal('9000000'));

        final outcome = _outcome(engine, truth144);

        expect(outcome.shown, isNot(decimal('9000000')));
        expect(outcome.kind, SabotageKind.nearMissOffset);
      },
    );

    test('should accept the same answer once lies may be bold', () {
      final engine = _engineAnswering(decimal('9000000'));

      final outcome = _outcome(engine, truth144, index: 5);

      expect(outcome.shown, decimal('9000000'));
    });

    test('should not draw a kind without weight', () {
      final engine = SabotageEngine(
        random: Random(1),
        config: const SabotageConfig(weights: {}),
      );

      expect(_outcome(engine, truth144).kind, SabotageKind.nearMissOffset);
    });
  });
}
