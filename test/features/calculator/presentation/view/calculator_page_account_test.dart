import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_page.dart';

import '../../../../helpers/pump_screen.dart';

Widget _page({VoidCallback? onAccountPressed}) {
  return RepositoryProvider<SabotageEngine>.value(
    value: SabotageEngine(random: Random(1)),
    child: CalculatorPage(onAccountPressed: onAccountPressed),
  );
}

void main() {
  testWidgets('should report the account button', (tester) async {
    var taps = 0;
    await pumpScreen(tester, _page(onAccountPressed: () => taps++));

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('should disable the account button without a hook', (
    tester,
  ) async {
    await pumpScreen(tester, _page());

    final button = tester.widget<SolennIconButton>(
      find.widgetWithIcon(SolennIconButton, Icons.person_outline_rounded),
    );

    expect(button.onPressed, isNull);
  });
}
