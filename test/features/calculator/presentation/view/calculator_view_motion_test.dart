import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_view.dart';

import '../../../../helpers/pump_screen.dart';

Widget _view({required bool reduced}) {
  final view = CalculatorView(
    expression: '',
    result: '0',
    onKeyPressed: (_) {},
  );
  if (!reduced) return view;
  return Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: view,
    ),
  );
}

Duration _bannerDuration(WidgetTester tester) =>
    tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration;

void main() {
  testWidgets('should slide the banner in by default', (tester) async {
    await pumpScreen(tester, _view(reduced: false));

    expect(_bannerDuration(tester), SolennMotion.defaults.base);
  });

  testWidgets('should show the banner at once when the user asked for less '
      'motion', (tester) async {
    await pumpScreen(tester, _view(reduced: true));

    expect(_bannerDuration(tester), Duration.zero);
  });
}
