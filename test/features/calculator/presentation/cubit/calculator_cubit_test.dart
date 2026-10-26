import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/calculation/calculation_outcome.dart';
import 'package:solenn/features/calculator/domain/calculation/calculation_pipeline.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_outcome.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_state.dart';

import '../../../../helpers/calculation_session.dart';
import '../../../../helpers/sabotage_fixtures.dart';

typedef _Call = ({EvaluationRequest request, int index});

/// Answers each request with the next prepared outcome and records the calls.
class _FakePipeline implements CalculationPipeline {
  _FakePipeline(this._outcomes);

  final List<CalculationOutcome> _outcomes;
  final List<_Call> calls = [];

  @override
  CalculationOutcome calculate(
    EvaluationRequest request, {
    required int calculationIndex,
  }) {
    calls.add((request: request, index: calculationIndex));
    return _outcomes.removeAt(0);
  }
}

CalculationOutcome _shows(String shown) => CalculationSucceeded(
  SabotageOutcome(
    truth: decimal('0'),
    shown: decimal(shown),
    kind: SabotageKind.nearMissOffset,
  ),
);

CalculationOutcome _fails() =>
    const CalculationFailed(EvaluationFailureKind.divisionByZero);

CalculatorCubit _cubit(List<CalculationOutcome> outcomes) =>
    CalculatorCubit(pipeline: _FakePipeline(outcomes));

void _press(CalculatorCubit cubit, String keys) {
  for (final character in keys.split('')) {
    cubit.pressKey(calculatorKeysByCharacter[character]!);
  }
}

void main() {
  group('typing', () {
    test('should start from an empty calculator', () {
      expect(_cubit([]).state, const CalculatorState());
    });

    test('should build the entry from digits', () {
      final cubit = _cubit([]);

      _press(cubit, '123');

      expect(cubit.state.input.entry, '123');
      expect(cubit.state.history, isEmpty);
      expect(cubit.state.committedCount, 0);
    });

    blocTest<CalculatorCubit, CalculatorState>(
      'should emit once per key that changes the input',
      build: () => _cubit([]),
      act: (cubit) => cubit.pressKey(CalculatorKey.five),
      expect: () => [
        const CalculatorState(input: CalculatorInputState(entry: '5')),
      ],
    );

    blocTest<CalculatorCubit, CalculatorState>(
      'should emit nothing for a key without effect',
      build: () => _cubit([]),
      act: (cubit) => cubit.pressKey(CalculatorKey.backspace),
      expect: () => <CalculatorState>[],
    );

    test('should not ask for an evaluation while typing', () {
      final pipeline = _FakePipeline([]);
      final cubit = CalculatorCubit(pipeline: pipeline);

      _press(cubit, '5+3');

      expect(pipeline.calls, isEmpty);
    });
  });

  group('calculating', () {
    test('should show the result of the pipeline', () {
      final cubit = _cubit([_shows('9')]);

      _press(cubit, '5+3=');

      expect(cubit.state.input.phase, InputPhase.evaluated);
      expect(cubit.state.input.result, '9');
      expect(cubit.state.committedCount, 1);
    });

    test('should send the typed expression to the pipeline', () {
      final pipeline = _FakePipeline([_shows('9')]);
      final cubit = CalculatorCubit(pipeline: pipeline);

      _press(cubit, '5+3=');

      expect(pipeline.calls.single.request.tokens, const [
        NumberToken('5'),
        OperatorToken(ArithmeticOperator.add),
        NumberToken('3'),
      ]);
    });

    test('should number the calculations from one', () {
      final pipeline = _FakePipeline([_shows('9'), _shows('20')]);
      final cubit = CalculatorCubit(pipeline: pipeline);

      _press(cubit, '5+3=C2*5=');

      expect(pipeline.calls.map((call) => call.index), [1, 2]);
      expect(cubit.state.committedCount, 2);
    });

    test('should repeat the operation on the displayed result', () {
      final pipeline = _FakePipeline([_shows('9'), _shows('12')]);
      final cubit = CalculatorCubit(pipeline: pipeline);

      _press(cubit, '5+3==');

      expect(pipeline.calls[1].index, 2);
      expect(pipeline.calls[1].request.tokens, const [
        NumberToken('9'),
        OperatorToken(ArithmeticOperator.add),
        NumberToken('3'),
      ]);
      expect(cubit.state.input.result, '12');
    });

    test('should continue from the displayed result', () {
      final cubit = _cubit([_shows('9')]);

      _press(cubit, '5+3=*');

      expect(cubit.state.input.tokens, const [
        NumberToken('9'),
        OperatorToken(ArithmeticOperator.multiply),
      ]);
    });
  });

  group('failing', () {
    test('should show the error without counting it', () {
      final cubit = _cubit([_fails()]);

      _press(cubit, '1/0=');

      expect(cubit.state.input.isError, isTrue);
      expect(cubit.state.committedCount, 0);
      expect(cubit.state.history, isEmpty);
    });

    test('should not use up a calculation number', () {
      final pipeline = _FakePipeline([_fails(), _shows('2')]);
      final cubit = CalculatorCubit(pipeline: pipeline);

      _press(cubit, '1/0=C1+1=');

      expect(pipeline.calls.map((call) => call.index), [1, 1]);
      expect(cubit.state.committedCount, 1);
    });
  });

  group('history', () {
    test('should list calculations newest first, with what was displayed', () {
      final cubit = _cubit([_shows('9'), _shows('20')]);

      _press(cubit, '5+3=C2*5=');

      expect(cubit.state.history.map((entry) => entry.result), ['20', '9']);
      expect(cubit.state.history.last.tokens, const [
        NumberToken('5'),
        OperatorToken(ArithmeticOperator.add),
        NumberToken('3'),
      ]);
    });

    test('should survive AC', () {
      final cubit = _cubit([_shows('9')]);

      _press(cubit, '5+3=C');

      expect(cubit.state.history, hasLength(1));
      expect(cubit.state.input, const CalculatorInputState());
    });

    test('should be erased by clearHistory, keeping the counter', () {
      final cubit = _cubit([_shows('9')]);
      _press(cubit, '5+3=');

      cubit.clearHistory();

      expect(cubit.state.history, isEmpty);
      expect(cubit.state.committedCount, 1);
      expect(cubit.state.input.result, '9');
    });

    blocTest<CalculatorCubit, CalculatorState>(
      'should emit nothing when there is nothing to clear',
      build: () => _cubit([]),
      act: (cubit) => cubit.clearHistory(),
      expect: () => <CalculatorState>[],
    );

    test('should keep only the most recent entries', () {
      final cubit = _cubit([for (var i = 0; i < 105; i++) _shows('$i')]);

      _press(cubit, '1+1=');
      for (var i = 0; i < 104; i++) {
        cubit.pressKey(CalculatorKey.equals);
      }

      expect(cubit.state.committedCount, 105);
      expect(cubit.state.history, hasLength(maxHistoryEntries));
      expect(cubit.state.history.first.result, '104');
      expect(cubit.state.history.last.result, '5');
    });
  });

  group('with the real pipeline', () {
    CalculatorCubit realCubit() => CalculatorCubit(
      pipeline: CalculationPipeline(
        sabotageEngine: SabotageEngine(random: Random(3)),
      ),
    );

    test('should show a wrong result', () {
      final cubit = realCubit();

      _press(cubit, '1+1=');

      expect(cubit.state.input.result, isNotNull);
      expect(cubit.state.input.result, isNot('2'));
    });

    test('should repeat the same lie for the same expression', () {
      final cubit = realCubit();

      _press(cubit, '1+1=');
      final first = cubit.state.input.result;
      _press(cubit, 'C1+1=');

      expect(cubit.state.input.result, first);
      expect(cubit.state.history, hasLength(2));
      expect(cubit.state.committedCount, 2);
    });

    test('should report an error for a division by zero', () {
      final cubit = realCubit();

      _press(cubit, '1/0=');

      expect(cubit.state.input.isError, isTrue);
    });
  });
}
