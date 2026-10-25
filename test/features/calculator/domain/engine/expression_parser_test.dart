import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/engine/expression_parser.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';

const ExpressionParser _parser = ExpressionParser();

const OperatorToken _add = OperatorToken(ArithmeticOperator.add);
const OperatorToken _subtract = OperatorToken(ArithmeticOperator.subtract);
const OperatorToken _multiply = OperatorToken(ArithmeticOperator.multiply);
const OperatorToken _divide = OperatorToken(ArithmeticOperator.divide);

NumberToken _n(String text) => NumberToken(text);
NumberToken _p(String text) => NumberToken(text, isPercent: true);

void main() {
  group('structure', () {
    test('should parse a lone operand', () {
      expect(_parser.parse([_n('5')]), const Literal('5'));
    });

    test('should parse a binary operation', () {
      expect(
        _parser.parse([_n('2'), _add, _n('3')]),
        const Binary(ArithmeticOperator.add, Literal('2'), Literal('3')),
      );
    });

    test('should bind multiplication tighter than addition', () {
      expect(
        _parser.parse([_n('2'), _add, _n('3'), _multiply, _n('4')]),
        const Binary(
          ArithmeticOperator.add,
          Literal('2'),
          Binary(ArithmeticOperator.multiply, Literal('3'), Literal('4')),
        ),
      );
    });

    test('should apply a leading multiplication first', () {
      expect(
        _parser.parse([_n('2'), _multiply, _n('3'), _add, _n('4')]),
        const Binary(
          ArithmeticOperator.add,
          Binary(ArithmeticOperator.multiply, Literal('2'), Literal('3')),
          Literal('4'),
        ),
      );
    });

    test('should group operators of equal precedence from the left', () {
      expect(
        _parser.parse([_n('10'), _subtract, _n('4'), _subtract, _n('3')]),
        const Binary(
          ArithmeticOperator.subtract,
          Binary(ArithmeticOperator.subtract, Literal('10'), Literal('4')),
          Literal('3'),
        ),
      );
      expect(
        _parser.parse([_n('8'), _divide, _n('4'), _divide, _n('2')]),
        const Binary(
          ArithmeticOperator.divide,
          Binary(ArithmeticOperator.divide, Literal('8'), Literal('4')),
          Literal('2'),
        ),
      );
    });

    test('should mix precedences in one expression', () {
      expect(
        _parser.parse([
          _n('2'),
          _add,
          _n('3'),
          _multiply,
          _n('4'),
          _subtract,
          _n('5'),
        ]),
        const Binary(
          ArithmeticOperator.subtract,
          Binary(
            ArithmeticOperator.add,
            Literal('2'),
            Binary(ArithmeticOperator.multiply, Literal('3'), Literal('4')),
          ),
          Literal('5'),
        ),
      );
    });
  });

  group('percent', () {
    test('should be a hundredth when it stands alone', () {
      expect(_parser.parse([_p('50')]), const Percent(Literal('50')));
    });

    test('should be a share of the left operand after an addition', () {
      expect(
        _parser.parse([_n('50'), _add, _p('10')]),
        const Binary(
          ArithmeticOperator.add,
          Literal('50'),
          Binary(
            ArithmeticOperator.multiply,
            Literal('50'),
            Percent(Literal('10')),
          ),
        ),
      );
    });

    test('should be a share of the left operand after a subtraction', () {
      expect(
        _parser.parse([_n('100'), _subtract, _p('10')]),
        const Binary(
          ArithmeticOperator.subtract,
          Literal('100'),
          Binary(
            ArithmeticOperator.multiply,
            Literal('100'),
            Percent(Literal('10')),
          ),
        ),
      );
    });

    test('should be a plain hundredth after a multiplication or division', () {
      expect(
        _parser.parse([_n('50'), _multiply, _p('10')]),
        const Binary(
          ArithmeticOperator.multiply,
          Literal('50'),
          Percent(Literal('10')),
        ),
      );
      expect(
        _parser.parse([_n('50'), _divide, _p('10')]),
        const Binary(
          ArithmeticOperator.divide,
          Literal('50'),
          Percent(Literal('10')),
        ),
      );
    });

    test('should use the running total as the base', () {
      const total = Binary(ArithmeticOperator.add, Literal('2'), Literal('3'));

      expect(
        _parser.parse([_n('2'), _add, _n('3'), _add, _p('10')]),
        const Binary(
          ArithmeticOperator.add,
          total,
          Binary(
            ArithmeticOperator.multiply,
            total,
            Percent(Literal('10')),
          ),
        ),
      );
    });

    test('should use the whole left expression as the base', () {
      const total = Binary(
        ArithmeticOperator.add,
        Literal('1'),
        Binary(ArithmeticOperator.multiply, Literal('2'), Literal('3')),
      );

      expect(
        _parser.parse([
          _n('1'),
          _add,
          _n('2'),
          _multiply,
          _n('3'),
          _add,
          _p('10'),
        ]),
        const Binary(
          ArithmeticOperator.add,
          total,
          Binary(
            ArithmeticOperator.multiply,
            total,
            Percent(Literal('10')),
          ),
        ),
      );
    });

    test(
      'should keep multiplying after a percent that follows an addition',
      () {
        expect(
          _parser.parse([_n('100'), _add, _p('10'), _multiply, _n('2')]),
          const Binary(
            ArithmeticOperator.add,
            Literal('100'),
            Binary(
              ArithmeticOperator.multiply,
              Binary(
                ArithmeticOperator.multiply,
                Literal('100'),
                Percent(Literal('10')),
              ),
              Literal('2'),
            ),
          ),
        );
      },
    );

    test('should treat a leading percent as a plain hundredth', () {
      expect(
        _parser.parse([_p('50'), _add, _p('50')]),
        const Binary(
          ArithmeticOperator.add,
          Percent(Literal('50')),
          Binary(
            ArithmeticOperator.multiply,
            Percent(Literal('50')),
            Percent(Literal('50')),
          ),
        ),
      );
    });
  });

  group('invalid tokens', () {
    test('should reject an empty list', () {
      expect(() => _parser.parse([]), throwsArgumentError);
    });

    test('should reject a trailing operator', () {
      expect(() => _parser.parse([_n('1'), _add]), throwsArgumentError);
    });

    test('should reject a leading operator', () {
      expect(
        () => _parser.parse([_add, _n('1'), _add]),
        throwsArgumentError,
      );
    });

    test('should reject adjacent operands', () {
      expect(
        () => _parser.parse([_n('1'), _n('2'), _n('3')]),
        throwsArgumentError,
      );
    });
  });
}
