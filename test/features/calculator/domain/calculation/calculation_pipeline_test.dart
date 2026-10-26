import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/calculation/calculation_outcome.dart';
import 'package:solenn/features/calculator/domain/calculation/calculation_pipeline.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_config.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_phase.dart';

import '../../../../helpers/sabotage_fixtures.dart';

EvaluationRequest _request(
  String left,
  ArithmeticOperator operation,
  String right,
) => EvaluationRequest(
  tokens: [NumberToken(left), OperatorToken(operation), NumberToken(right)],
);

CalculationPipeline _pipeline({SabotageConfig? config}) => CalculationPipeline(
  sabotageEngine: SabotageEngine(
    random: Random(1),
    config: config ?? SabotageConfig.standard,
  ),
);

CalculationSucceeded _succeeded(CalculationOutcome outcome) {
  expect(outcome, isA<CalculationSucceeded>());
  return outcome as CalculationSucceeded;
}

void main() {
  final fivePlusThree = _request('5', ArithmeticOperator.add, '3');

  group('on success', () {
    test('should lie about the exact result', () {
      final outcome = _succeeded(
        _pipeline().calculate(fivePlusThree, calculationIndex: 1),
      );

      expect(outcome.sabotage.truth, decimal('8'));
      expect(outcome.result, isNot('8'));
      expect(outcome.result, outcome.sabotage.shownText);
    });

    test('should give the same lie to the same expression', () {
      final pipeline = _pipeline();

      final first = pipeline.calculate(fivePlusThree, calculationIndex: 1);
      final again = pipeline.calculate(fivePlusThree, calculationIndex: 7);

      expect(again, first);
    });

    test('should let the calculation index decide how daring the lie is', () {
      const config = SabotageConfig(
        weights: {
          SabotagePhase.plausible: {SabotageKind.digitShuffle: 1},
          SabotagePhase.bold: {SabotageKind.roundingAbuse: 1},
        },
      );
      final request = _request('100', ArithmeticOperator.add, '44');

      final early = _succeeded(
        _pipeline(config: config).calculate(request, calculationIndex: 1),
      );
      final later = _succeeded(
        _pipeline(config: config).calculate(request, calculationIndex: 5),
      );

      expect(early.sabotage.kind, SabotageKind.digitShuffle);
      expect(early.result, '414');
      expect(later.sabotage.kind, SabotageKind.roundingAbuse);
      expect(later.result, '100');
    });

    test('should handle a lone percent', () {
      final outcome = _succeeded(
        _pipeline().calculate(
          const EvaluationRequest(tokens: [NumberToken('5', isPercent: true)]),
          calculationIndex: 1,
        ),
      );

      expect(outcome.sabotage.truth, decimal('0.05'));
      expect(outcome.result, isNot('0.05'));
    });
  });

  group('on failure', () {
    test('should report a division by zero without lying', () {
      final outcome = _pipeline().calculate(
        _request('1', ArithmeticOperator.divide, '0'),
        calculationIndex: 1,
      );

      expect(
        outcome,
        const CalculationFailed(EvaluationFailureKind.divisionByZero),
      );
    });

    test('should report an overflow', () {
      final outcome = _pipeline().calculate(
        _request('1${'0' * 99}', ArithmeticOperator.multiply, '10'),
        calculationIndex: 1,
      );

      expect(outcome, const CalculationFailed(EvaluationFailureKind.overflow));
    });
  });

  test('should compare outcomes by value', () {
    expect(
      const CalculationFailed(EvaluationFailureKind.overflow),
      const CalculationFailed(EvaluationFailureKind.overflow),
    );
    expect(
      const CalculationFailed(EvaluationFailureKind.overflow),
      isNot(const CalculationFailed(EvaluationFailureKind.divisionByZero)),
    );
  });
}
