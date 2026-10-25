import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/sabotage/expression_key.dart';

import '../../../../helpers/sabotage_fixtures.dart';

void main() {
  test('should give the same key to the same expression', () {
    expect(
      expressionKey(binary(ArithmeticOperator.add, '2', '3')),
      expressionKey(binary(ArithmeticOperator.add, '2', '3')),
    );
  });

  test('should compare numbers by value', () {
    expect(
      expressionKey(binary(ArithmeticOperator.add, '1.50', '2')),
      expressionKey(binary(ArithmeticOperator.add, '1.5', '2')),
    );
  });

  test('should keep the operand order', () {
    expect(
      expressionKey(binary(ArithmeticOperator.add, '2', '3')),
      isNot(expressionKey(binary(ArithmeticOperator.add, '3', '2'))),
    );
  });

  test('should distinguish operators', () {
    expect(
      expressionKey(binary(ArithmeticOperator.add, '2', '3')),
      isNot(expressionKey(binary(ArithmeticOperator.multiply, '2', '3'))),
    );
  });

  test('should distinguish a percent from its operand', () {
    expect(
      expressionKey(const Percent(Literal('5'))),
      isNot(expressionKey(const Literal('5'))),
    );
  });

  test('should keep the structure of nested expressions', () {
    const flat = Binary(
      ArithmeticOperator.add,
      Binary(ArithmeticOperator.add, Literal('1'), Literal('2')),
      Literal('3'),
    );
    const nested = Binary(
      ArithmeticOperator.add,
      Literal('1'),
      Binary(ArithmeticOperator.add, Literal('2'), Literal('3')),
    );

    expect(expressionKey(flat), isNot(expressionKey(nested)));
  });
}
