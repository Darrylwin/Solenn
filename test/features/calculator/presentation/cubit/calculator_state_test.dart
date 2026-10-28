import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/history/history_entry.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_outcome.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_state.dart';

import '../../../../helpers/sabotage_fixtures.dart';

void main() {
  const entry = HistoryEntry(tokens: [NumberToken('5')], result: '5');

  test('should start with an empty input, no history and no calculation', () {
    const state = CalculatorState();

    expect(state.input, const CalculatorInputState());
    expect(state.history, isEmpty);
    expect(state.committedCount, 0);
  });

  test('should keep every value a copy does not replace', () {
    const state = CalculatorState(
      input: CalculatorInputState(entry: '5'),
      history: [entry],
      committedCount: 3,
    );

    final copy = state.copyWith(committedCount: 4);

    expect(copy.input, state.input);
    expect(copy.history, state.history);
    expect(copy.committedCount, 4);
  });

  test('should replace each value separately', () {
    const state = CalculatorState();

    expect(
      state.copyWith(input: const CalculatorInputState(entry: '7')).input.entry,
      '7',
    );
    expect(state.copyWith(history: const [entry]).history, const [entry]);
  });

  test('should compare states by value, history included', () {
    expect(
      const CalculatorState(history: [entry]),
      const CalculatorState(history: [entry]),
    );
    expect(
      const CalculatorState(history: [entry]),
      isNot(const CalculatorState()),
    );
  });

  test('should keep the last outcome through copies and compare it', () {
    final outcome = SabotageOutcome(
      truth: decimal('8'),
      shown: decimal('9'),
      kind: SabotageKind.nearMissOffset,
    );
    final state = CalculatorState(lastOutcome: outcome);

    expect(state.copyWith(committedCount: 1).lastOutcome, outcome);
    expect(state, CalculatorState(lastOutcome: outcome));
    expect(state, isNot(const CalculatorState()));
  });
}
