import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

void main() {
  test('should compare literals by their text', () {
    expect(const Literal('5'), const Literal('5'));
    expect(const Literal('5'), isNot(const Literal('6')));
  });

  test('should compare trees structurally', () {
    const tree = Binary(
      ArithmeticOperator.add,
      Literal('1'),
      Percent(Literal('2')),
    );

    expect(
      tree,
      const Binary(
        ArithmeticOperator.add,
        Literal('1'),
        Percent(Literal('2')),
      ),
    );
    expect(
      tree,
      isNot(
        const Binary(
          ArithmeticOperator.subtract,
          Literal('1'),
          Percent(Literal('2')),
        ),
      ),
    );
  });
}
