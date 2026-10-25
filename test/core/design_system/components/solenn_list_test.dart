import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

void main() {
  group('SolennListTile', () {
    testWidgets('should call onPressed and show a chevron', (tester) async {
      var taps = 0;
      await pumpScreen(
        tester,
        Center(
          child: SolennListTile(title: 'Terms', onPressed: () => taps++),
        ),
      );

      await tester.tap(find.text('Terms'));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('should be informative without a callback', (tester) async {
      await pumpScreen(
        tester,
        const Center(
          child: SolennListTile(title: 'Version', value: '0.1.0'),
        ),
      );

      expect(find.text('0.1.0'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('should be at least 56 pixels tall', (tester) async {
      await pumpScreen(
        tester,
        const Center(child: SolennListTile(title: 'Version')),
      );

      expect(
        tester.getSize(find.byType(SolennListTile)).height,
        greaterThanOrEqualTo(56),
      );
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should meet tap target guidelines on $platform', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(
          tester,
          Center(
            child: SolennListTile(title: 'Terms', onPressed: () {}),
          ),
          platform: platform,
        );

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('should not overflow with a long value and large text', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const Center(
          child: SolennListTile(
            title: 'Open-source licenses',
            value: '0.1.0 (1) release candidate',
          ),
        ),
        size: const Size(320, 568),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('SolennListGroup', () {
    testWidgets('should separate tiles with one divider each', (tester) async {
      await pumpScreen(
        tester,
        const Center(
          child: SolennListGroup(
            children: [
              SolennListTile(title: 'One'),
              SolennListTile(title: 'Two'),
              SolennListTile(title: 'Three'),
            ],
          ),
        ),
      );

      expect(find.byKey(solennListDividerKey), findsNWidgets(2));
    });

    testWidgets('should have no divider with a single tile', (tester) async {
      await pumpScreen(
        tester,
        const Center(
          child: SolennListGroup(children: [SolennListTile(title: 'One')]),
        ),
      );

      expect(find.byKey(solennListDividerKey), findsNothing);
    });
  });
}
