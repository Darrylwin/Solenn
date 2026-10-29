@Tags(<String>['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_view.dart';

import '../../../../helpers/golden_helpers.dart';
import '../../../../helpers/load_app_fonts.dart';
import '../../../../helpers/pump_screen.dart';

typedef _Scenario = ({
  String name,
  String expression,
  String result,
  String? caption,
  CalculatorKey? selected,
  bool unlocked,
});

const List<_Scenario> _scenarios = [
  (
    name: 'empty',
    expression: '',
    result: '0',
    caption: null,
    selected: null,
    unlocked: false,
  ),
  (
    name: 'typing',
    expression: '24,000 +',
    result: '220',
    caption: null,
    selected: null,
    unlocked: false,
  ),
  (
    name: 'result',
    expression: '24,000 + 220',
    result: '24,820',
    caption: 'Verified · 99.9% accuracy',
    selected: null,
    unlocked: false,
  ),
  (
    name: 'operator',
    expression: '5 +',
    result: '5',
    caption: null,
    selected: CalculatorKey.add,
    unlocked: false,
  ),
  (
    name: 'unlocked',
    expression: '24,000 + 220',
    result: '24,820',
    caption: 'Verified · 99.9% accuracy',
    selected: null,
    unlocked: true,
  ),
  (
    name: 'error',
    expression: '1 \u00F7 0',
    result: 'Error',
    caption: null,
    selected: null,
    unlocked: false,
  ),
];

CalculatorView _view(_Scenario scenario) => CalculatorView(
  expression: scenario.expression,
  result: scenario.result,
  caption: scenario.caption,
  selectedOperator: scenario.selected,
  headerCenter: scenario.unlocked ? const SolennChip(label: 'PLUS') : null,
  banner: scenario.unlocked
      ? const SolennBanner(
          title: 'Welcome to Solenn Plus',
          message: 'Your plan is active. Calculate without limits.',
        )
      : null,
  onKeyPressed: (_) {},
  onHistoryPressed: () {},
  onAccountPressed: () {},
);

void main() {
  setUpAll(loadAppFonts);

  for (final scenario in _scenarios) {
    for (final width in goldenWidths) {
      testWidgets(
        'should match the golden of the ${scenario.name} state at $width',
        (tester) async {
          await pumpScreen(tester, _view(scenario), size: phoneSize(width));
          await tester.pumpAndSettle();

          await expectScreenGolden(
            goldenName('calculator-${scenario.name}', width),
          );
        },
      );
    }
  }
}
