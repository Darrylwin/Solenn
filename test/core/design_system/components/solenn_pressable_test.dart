import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/components/solenn_pressable.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

Widget _pressable({VoidCallback? onPressed}) {
  return Center(
    child: SizedBox.square(
      dimension: 80,
      child: SolennPressable(
        shape: const CircleBorder(),
        overlayColor: const Color(0x33FFFFFF),
        onPressed: onPressed,
        child: const SizedBox.expand(),
      ),
    ),
  );
}

void main() {
  testWidgets('should not leave a pressed veil when disabled on iOS', (
    tester,
  ) async {
    await pumpScreen(tester, _pressable(), platform: TargetPlatform.iOS);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SolennPressable)),
    );
    await tester.pump(SolennMotion.defaults.press);

    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(SolennPressable),
        matching: find.byType(AnimatedContainer),
      ),
    );

    expect(
      (container.decoration! as ShapeDecoration).color,
      Colors.transparent,
    );
    await gesture.up();
  });

  testWidgets('should render a ripple surface on Android', (tester) async {
    await pumpScreen(tester, _pressable(onPressed: () {}));

    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets('should render a gesture surface without ripple on iOS', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _pressable(onPressed: () {}),
      platform: TargetPlatform.iOS,
    );

    expect(find.byType(InkWell), findsNothing);
  });
}
