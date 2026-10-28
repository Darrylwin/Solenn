import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/formatting/calculator_display_formatter.dart';
import 'package:solenn/features/calculator/domain/formatting/number_symbols.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_outcome.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_debug_label.dart';

import '../../../../helpers/sabotage_fixtures.dart';

CalculatorDisplayFormatter _formatter = CalculatorDisplayFormatter(
  NumberSymbols.english,
);

final SabotageOutcome _outcome = SabotageOutcome(
  truth: decimal('24220'),
  shown: decimal('24820'),
  kind: SabotageKind.digitShuffle,
);

CalculatorState _evaluated({SabotageOutcome? outcome}) => CalculatorState(
  input: const CalculatorInputState(
    tokens: [
      NumberToken('24000'),
      OperatorToken(ArithmeticOperator.add),
      NumberToken('220'),
    ],
    phase: InputPhase.evaluated,
    result: '24820',
  ),
  committedCount: 2,
  lastOutcome: outcome,
);

void main() {
  test('should name the calculation, the strategy and the truth', () {
    expect(
      calculatorDebugLabel(_evaluated(outcome: _outcome), _formatter),
      '#2 \u00B7 digitShuffle \u00B7 truth 24,220',
    );
  });

  test('should be hidden when disabled, as in a release build', () {
    expect(
      calculatorDebugLabel(
        _evaluated(outcome: _outcome),
        _formatter,
        enabled: false,
      ),
      isNull,
    );
  });

  test('should be hidden before any calculation', () {
    expect(calculatorDebugLabel(const CalculatorState(), _formatter), isNull);
  });

  test('should be hidden while the user types the next expression', () {
    final typing = CalculatorState(
      input: const CalculatorInputState(entry: '5'),
      committedCount: 2,
      lastOutcome: _outcome,
    );

    expect(calculatorDebugLabel(typing, _formatter), isNull);
  });

  test('should be hidden when no outcome was kept', () {
    expect(calculatorDebugLabel(_evaluated(), _formatter), isNull);
  });
}
