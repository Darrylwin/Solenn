import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart' hide isNegative, isZero;
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/display_key.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/near_miss_offset.dart';

import '../../../../../helpers/sabotage_fixtures.dart';

const NearMissOffset _strategy = NearMissOffset();

Iterable<Decimal> _offsets(Expression expression) sync* {
  for (var seed = 0; seed < 200; seed++) {
    yield _strategy.offset(contextFor(expression, seed: seed));
  }
}

void main() {
  test('should be the nearMissOffset kind', () {
    expect(_strategy.kind, SabotageKind.nearMissOffset);
  });

  test('should shift the digits of a large number', () {
    final expression = binary(ArithmeticOperator.add, '24000', '220');
    final truth = truthOf(expression);

    for (final shown in _offsets(expression)) {
      final difference = (shown - truth).abs();

      expect(difference.compareTo(decimal('100')), greaterThanOrEqualTo(0));
      expect(difference.compareTo(decimal('30000')), lessThanOrEqualTo(0));
      expect(canonicalText(difference), endsWith('00'));
      expect(isNegative(shown), isFalse);
      expect(displayKey(shown), isNot(displayKey(truth)));
    }
  });

  test('should shift a single digit by one to three units', () {
    final expression = binary(ArithmeticOperator.add, '5', '3');
    final truth = truthOf(expression);

    for (final shown in _offsets(expression)) {
      final difference = (shown - truth).abs();

      expect(difference.compareTo(decimal('1')), greaterThanOrEqualTo(0));
      expect(difference.compareTo(decimal('3')), lessThanOrEqualTo(0));
    }
  });

  test('should keep a negative truth negative', () {
    final expression = binary(ArithmeticOperator.subtract, '3', '5');

    for (final shown in _offsets(expression)) {
      expect(isNegative(shown), isTrue);
      expect(isZero(shown), isFalse);
    }
  });

  test('should never reach zero or flip the sign of a small truth', () {
    final expression = binary(ArithmeticOperator.subtract, '3', '2');

    final texts = _offsets(expression).map(canonicalText).toSet();

    expect(texts, everyElement(isIn(['2', '3', '4'])));
  });

  test('should answer a small positive number for a zero truth', () {
    final expression = binary(ArithmeticOperator.subtract, '5', '5');

    final texts = _offsets(expression).map(canonicalText).toSet();

    expect(texts, {'1', '2', '3'});
  });

  test('should stay in range at the top and bottom of the range', () {
    for (final text in [
      '9${'0' * 99}',
      '1${'0' * 99}',
      '-9${'0' * 99}',
      '0.${'0' * 98}1',
      '-0.${'0' * 98}1',
    ]) {
      for (final shown in _offsets(Literal(text))) {
        expect(isOutOfRange(shown), isFalse, reason: text);
        expect(isZero(shown), isFalse, reason: text);
      }
    }
  });

  test('should also be reachable through apply', () {
    final context = contextFor(binary(ArithmeticOperator.add, '5', '3'));

    expect(_strategy.apply(context), isNotNull);
  });
}
