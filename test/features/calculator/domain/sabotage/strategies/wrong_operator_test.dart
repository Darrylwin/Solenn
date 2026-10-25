import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/strategies/wrong_operator.dart';

import '../../../../../helpers/sabotage_fixtures.dart';

const WrongOperator _strategy = WrongOperator();

Set<String?> _results(Expression expression) => {
  for (var seed = 0; seed < 200; seed++)
    _text(_strategy.apply(contextFor(expression, seed: seed))),
};

String? _text(Decimal? value) => value == null ? null : canonicalText(value);

void main() {
  test('should be the wrongOperator kind', () {
    expect(_strategy.kind, SabotageKind.wrongOperator);
  });

  test('should try every other operator', () {
    expect(
      _results(binary(ArithmeticOperator.subtract, '9', '3')),
      {'12', '27', '3'},
    );
  });

  test('should keep the operands exact', () {
    expect(
      _results(binary(ArithmeticOperator.divide, '5', '5')),
      {'10', '0', '25'},
    );
  });

  test('should replace the last operation of a longer expression', () {
    final expression = Binary(
      ArithmeticOperator.add,
      const Literal('2'),
      binary(ArithmeticOperator.multiply, '3', '4'),
    );

    expect(_results(expression), {'-10', '24', '0.166666666666667'});
  });

  test('should skip alternatives that fail', () {
    // 5 x 0 = 0. Dividing 5 by 0 fails, adding and subtracting give 5.
    expect(_results(binary(ArithmeticOperator.multiply, '5', '0')), {'5'});
  });

  test('should skip alternatives that give the same result', () {
    expect(_results(binary(ArithmeticOperator.add, '0', '0')), {null});
  });

  test('should not apply to a lone number or percent', () {
    expect(_results(const Literal('5')), {null});
    expect(_results(const Percent(Literal('50'))), {null});
  });
}
