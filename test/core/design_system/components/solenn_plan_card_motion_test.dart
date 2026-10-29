import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

Widget _card({required bool reduced}) {
  final card = Center(
    child: SolennPlanCard(
      title: 'Annual',
      price: r'$39.99',
      selected: true,
      semanticLabel: 'Annual plan',
      onPressed: () {},
    ),
  );
  if (!reduced) return card;
  return Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: card,
    ),
  );
}

List<Duration> _durations(WidgetTester tester) => tester
    .widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byType(SolennPlanCard),
        matching: find.byType(AnimatedContainer),
      ),
    )
    .map((container) => container.duration)
    .toList();

void main() {
  testWidgets('should animate its selection by default', (tester) async {
    await pumpScreen(tester, _card(reduced: false));

    final durations = _durations(tester);

    expect(durations, isNotEmpty);
    expect(durations, everyElement(SolennMotion.defaults.fast));
  });

  testWidgets('should not animate when the user asked for less motion', (
    tester,
  ) async {
    await pumpScreen(tester, _card(reduced: true));

    final durations = _durations(tester);

    expect(durations, isNotEmpty);
    expect(durations, everyElement(Duration.zero));
  });
}
