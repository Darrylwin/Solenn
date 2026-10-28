import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_page.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';

import '../../../../helpers/pump_screen.dart';

const Map<String, String> _labels = {'/': '\u00F7', 'C': 'AC'};

Finder _key(String label) => find.descendant(
  of: find.byType(CalculatorKeypad),
  matching: find.text(label),
);

Future<void> _type(WidgetTester tester, String keys) async {
  for (final character in keys.split('')) {
    await tester.tap(_key(_labels[character] ?? character));
    await tester.pump();
  }
}

Future<void> _pumpPage(WidgetTester tester, void Function() onCommitted) {
  return pumpScreen(
    tester,
    RepositoryProvider<SabotageEngine>.value(
      value: SabotageEngine(random: Random(1)),
      child: CalculatorPage(onCalculationCommitted: onCommitted),
    ),
  );
}

void main() {
  testWidgets('should report every successful calculation', (tester) async {
    var commits = 0;
    await _pumpPage(tester, () => commits++);

    await _type(tester, '1+1=');
    expect(commits, 1);

    await _type(tester, 'C2+2=');
    expect(commits, 2);
  });

  testWidgets('should not report typing, errors or a lone number', (
    tester,
  ) async {
    var commits = 0;
    await _pumpPage(tester, () => commits++);

    await _type(tester, '5+3');
    await _type(tester, 'C1/0=');
    await _type(tester, 'C7=');

    expect(commits, 0);
  });

  testWidgets('should report a repeated equals as a new calculation', (
    tester,
  ) async {
    var commits = 0;
    await _pumpPage(tester, () => commits++);

    await _type(tester, '1+1==');

    expect(commits, 2);
  });

  testWidgets('should work without a hook', (tester) async {
    await pumpScreen(
      tester,
      RepositoryProvider<SabotageEngine>.value(
        value: SabotageEngine(random: Random(1)),
        child: const CalculatorPage(),
      ),
    );

    await _type(tester, '1+1=');

    expect(tester.takeException(), isNull);
  });
}
