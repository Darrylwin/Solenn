import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/input/repeat_operation.dart';

void main() {
  group('EvaluationRequest.repeatOperation', () {
    test('should be the last operator and its right operand', () {
      const request = EvaluationRequest(
        tokens: [
          NumberToken('2'),
          OperatorToken(ArithmeticOperator.add),
          NumberToken('3'),
          OperatorToken(ArithmeticOperator.multiply),
          NumberToken('4'),
        ],
      );

      expect(
        request.repeatOperation,
        const RepeatOperation(
          operation: ArithmeticOperator.multiply,
          operand: NumberToken('4'),
        ),
      );
    });

    test('should keep the percent sign of the operand', () {
      const request = EvaluationRequest(
        tokens: [
          NumberToken('50'),
          OperatorToken(ArithmeticOperator.add),
          NumberToken('10', isPercent: true),
        ],
      );

      expect(request.repeatOperation?.operand.isPercent, isTrue);
    });

    test('should be null without an operator', () {
      const request = EvaluationRequest(
        tokens: [NumberToken('5', isPercent: true)],
      );

      expect(request.repeatOperation, isNull);
    });
  });

  test('should compare requests by their tokens', () {
    const tokens = [
      NumberToken('1'),
      OperatorToken(ArithmeticOperator.add),
      NumberToken('1'),
    ];

    expect(
      const EvaluationRequest(tokens: tokens),
      const EvaluationRequest(tokens: tokens),
    );
  });
}
