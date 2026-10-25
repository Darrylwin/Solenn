import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/account/presentation/account/account_view.dart';

import '../../../../helpers/pump_screen.dart';

class _Calls {
  final List<String> events = [];

  AccountView view({String? badge = 'PLUS'}) => AccountView(
    planName: 'Solenn Plus',
    planDetail: 'Annual · 7-day free trial',
    planBadge: badge,
    versionLabel: '0.1.0 (1)',
    onBackPressed: () => events.add('back'),
    onRestorePressed: () => events.add('restore'),
    onTermsPressed: () => events.add('terms'),
    onPrivacyPressed: () => events.add('privacy'),
    onLicensesPressed: () => events.add('licenses'),
  );
}

void main() {
  group('AccountView content', () {
    testWidgets('should show the plan, the sections and the version', (
      tester,
    ) async {
      await pumpScreen(tester, _Calls().view());

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Solenn Plus'), findsOneWidget);
      expect(find.text('Annual · 7-day free trial'), findsOneWidget);
      expect(find.text('PLUS'), findsOneWidget);
      expect(find.text('SUBSCRIPTION'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Open-source licenses'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('0.1.0 (1)'), findsOneWidget);
    });

    testWidgets('should omit the badge when there is none', (tester) async {
      await pumpScreen(tester, _Calls().view(badge: null));

      expect(find.byType(SolennChip), findsNothing);
    });

    testWidgets('should expose four tappable rows and one informative row', (
      tester,
    ) async {
      await pumpScreen(tester, _Calls().view());

      expect(find.byType(SolennListTile), findsNWidgets(5));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(4));
    });
  });

  group('AccountView interaction', () {
    testWidgets('should report each row separately', (tester) async {
      final calls = _Calls();
      await pumpScreen(tester, calls.view());

      for (final label in [
        'Restore purchases',
        'Terms of Service',
        'Privacy Policy',
        'Open-source licenses',
      ]) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(calls.events, ['restore', 'terms', 'privacy', 'licenses', 'back']);
    });

    testWidgets('should not react when the version is tapped', (tester) async {
      final calls = _Calls();
      await pumpScreen(tester, calls.view());

      await tester.tap(find.text('0.1.0 (1)'));
      await tester.pumpAndSettle();

      expect(calls.events, isEmpty);
    });
  });

  group('AccountView accessibility and layout', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should meet guidelines on $platform', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, _Calls().view(), platform: platform);

        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      for (final size in const [
        Size(320, 568),
        Size(390, 844),
        Size(768, 1024),
      ]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('should not overflow at $size, x$scale on $platform', (
            tester,
          ) async {
            await pumpScreen(
              tester,
              _Calls().view(),
              platform: platform,
              size: size,
              textScale: scale,
            );

            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('should scroll to the last row on a small screen', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _Calls().view(),
        size: const Size(320, 480),
        textScale: 2,
      );

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -3000),
      );
      await tester.pumpAndSettle();

      expect(find.text('0.1.0 (1)'), findsOneWidget);
    });
  });
}
