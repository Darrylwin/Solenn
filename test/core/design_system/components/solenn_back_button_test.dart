import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

Widget _button({VoidCallback? onPressed}) => Center(
  child: SolennBackButton(semanticLabel: 'Back', onPressed: onPressed),
);

void main() {
  testWidgets('should use the Material arrow on Android', (tester) async {
    await pumpScreen(tester, _button(onPressed: () {}));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
  });

  testWidgets('should use the chevron on iOS', (tester) async {
    await pumpScreen(
      tester,
      _button(onPressed: () {}),
      platform: TargetPlatform.iOS,
    );

    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('should be tappable and labeled on $platform', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpScreen(
        tester,
        _button(onPressed: () => taps++),
        platform: platform,
      );

      await tester.tap(find.byType(SolennBackButton));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      handle.dispose();
    });
  }
}
