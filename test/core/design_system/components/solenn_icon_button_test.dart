import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

Widget _button({VoidCallback? onPressed}) => Center(
  child: SolennIconButton(
    icon: Icons.history_rounded,
    semanticLabel: 'History',
    onPressed: onPressed,
  ),
);

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    group('SolennIconButton on $platform', () {
      testWidgets('should call onPressed when tapped', (tester) async {
        var taps = 0;
        await pumpScreen(
          tester,
          _button(onPressed: () => taps++),
          platform: platform,
        );

        await tester.tap(find.byType(SolennIconButton));
        await tester.pumpAndSettle();

        expect(taps, 1);
      });

      testWidgets('should expose its label and meet tap target guidelines', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, _button(onPressed: () {}), platform: platform);

        expect(find.bySemanticsLabel('History'), findsOneWidget);
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    });
  }

  testWidgets('should be 44 logical pixels wide', (tester) async {
    await pumpScreen(tester, _button(onPressed: () {}));

    expect(tester.getSize(find.byType(SolennIconButton)), const Size(44, 44));
  });

  testWidgets('should render when disabled', (tester) async {
    await pumpScreen(tester, _button());

    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
  });
}
