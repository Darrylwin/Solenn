import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
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

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(SolennReveal),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

Future<void> _pumpPage(WidgetTester tester) => pumpScreen(
  tester,
  RepositoryProvider<SabotageEngine>.value(
    value: SabotageEngine(random: Random(1)),
    child: const CalculatorPage(),
  ),
);

void main() {
  testWidgets('should show what is typed at once', (tester) async {
    await _pumpPage(tester);

    await _type(tester, '24000');

    expect(_opacity(tester), 1);
  });

  testWidgets('should fade a result in', (tester) async {
    await _pumpPage(tester);

    await _type(tester, '1+1=');
    expect(_opacity(tester), lessThan(1));

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_opacity(tester), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets('should fade each new result in', (tester) async {
    await _pumpPage(tester);
    await _type(tester, '1+1=');
    await tester.pumpAndSettle();

    await _type(tester, 'C2+2=');

    expect(_opacity(tester), lessThan(1));
  });

  testWidgets('should show the next entry at once after a result', (
    tester,
  ) async {
    await _pumpPage(tester);
    await _type(tester, '1+1=');
    expect(_opacity(tester), lessThan(1));

    await _type(tester, '5');

    expect(_opacity(tester), 1);
  });

  testWidgets('should not fade an error', (tester) async {
    await _pumpPage(tester);

    await _type(tester, '1/0=');

    expect(_opacity(tester), 1);
  });
}
