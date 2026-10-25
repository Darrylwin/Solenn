import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/digit_shuffle.dart';

import '../../../../../helpers/sabotage_fixtures.dart';

const DigitShuffle _strategy = DigitShuffle();

Set<String> _results(Expression expression) => {
  for (var seed = 0; seed < 200; seed++)
    canonicalText(_strategy.apply(contextFor(expression, seed: seed))!),
};

void main() {
  test('should be the digitShuffle kind', () {
    expect(_strategy.kind, SabotageKind.digitShuffle);
  });

  test('should swap the only possible pair', () {
    expect(
      _results(binary(ArithmeticOperator.multiply, '36', '4')),
      {'414'},
    );
  });

  test('should pick among the possible pairs', () {
    expect(
      _results(binary(ArithmeticOperator.add, '100', '23')),
      {'213', '132'},
    );
  });

  test('should keep the digits and the magnitude', () {
    const truth = '24820';

    for (final text in _results(
      binary(ArithmeticOperator.add, '24000', '820'),
    )) {
      expect(text, isNot(truth));
      expect(text.split('')..sort(), truth.split('')..sort());
      expect(text.length, truth.length);
    }
  });

  test('should shuffle the digits of a fraction', () {
    expect(
      _results(binary(ArithmeticOperator.divide, '1', '4')),
      {'0.52'},
    );
  });

  test('should keep the sign', () {
    expect(_results(const Literal('-12')), {'-21'});
  });

  test('should never put a zero in front', () {
    // 105: swapping the first two digits would read 015.
    for (final text in _results(const Literal('105'))) {
      expect(text, isNot('15'));
      expect(text.length, 3);
    }
  });

  group('when it does not apply', () {
    final _ =
        {
          'a single digit': binary(ArithmeticOperator.add, '2', '3'),
          'identical digits': binary(ArithmeticOperator.add, '5', '6'),
          'a lone leading digit followed by zeros': binary(
            ArithmeticOperator.multiply,
            '10',
            '10',
          ),
          'zero': binary(ArithmeticOperator.subtract, '5', '5'),
          'a repeating fraction': binary(ArithmeticOperator.divide, '1', '3'),
        }..forEach((name, expression) {
          test('should give up on $name', () {
            expect(_strategy.apply(contextFor(expression)), isNull);
          });
        });
  });
}
