import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/components/solenn_plan_card.dart';
import 'package:solenn/core/design_system/components/solenn_primary_button.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_plan_option.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';

import '../../../../helpers/fake_haptics_service.dart';
import '../../../../helpers/pump_screen.dart';

const List<PaywallPlanOption> _plans = [
  PaywallPlanOption(
    id: 'annual',
    title: 'Annual',
    subtitle: r'7-day free trial · $3.33 / month',
    price: r'$39.99',
    anchorPrice: r'$59.88',
    badge: 'BEST VALUE · SAVE 33%',
    semanticLabel: 'Annual plan',
  ),
  PaywallPlanOption(
    id: 'monthly',
    title: 'Monthly',
    subtitle: 'Billed monthly · Cancel anytime',
    price: r'$4.99',
    semanticLabel: 'Monthly plan',
  ),
  PaywallPlanOption(
    id: 'enterprise',
    title: 'Enterprise',
    subtitle: 'Slightly less wrong results',
    price: r'$149.99',
    semanticLabel: 'Enterprise plan',
    dense: true,
  ),
];

// Tall enough to show the whole paywall, so taps never miss off-screen items.
const Size _tall = Size(390, 1600);

class _Calls {
  final List<String> events = [];

  PaywallView view({String selected = 'annual'}) => PaywallView(
    plans: _plans,
    selectedPlanId: selected,
    ctaLabel: 'Start 7-day free trial',
    finePrint: r'Then $39.99 / year',
    socialProofCount: 12482,
    onPlanSelected: (id) => events.add('plan:$id'),
    onPurchasePressed: () => events.add('purchase'),
    onClosePressed: () => events.add('close'),
    onDeclinePressed: () => events.add('decline'),
    onRestorePressed: () => events.add('restore'),
    onTermsPressed: () => events.add('terms'),
    onPrivacyPressed: () => events.add('privacy'),
    onSystemBackPressed: () => events.add('back'),
  );
}

void main() {
  group('PaywallView content', () {
    testWidgets('should show the headline, the offer and the proof', (
      tester,
    ) async {
      await pumpScreen(tester, _Calls().view(), size: _tall);

      expect(find.textContaining('Unlock', findRichText: true), findsOneWidget);
      expect(
        find.textContaining('Precision™', findRichText: true),
        findsOneWidget,
      );
      expect(find.textContaining('Unlimited results'), findsOneWidget);
      expect(find.text('Trusted by 12,482 professionals'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    });

    testWidgets('should show every plan and the call to action', (
      tester,
    ) async {
      await pumpScreen(tester, _Calls().view(), size: _tall);

      expect(find.byType(SolennPlanCard), findsNWidgets(3));
      expect(find.text('BEST VALUE · SAVE 33%'), findsOneWidget);
      expect(find.text('Start 7-day free trial'), findsOneWidget);
      expect(find.text('I prefer inaccurate results'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    testWidgets('should show the fine print with the offer countdown', (
      tester,
    ) async {
      await pumpScreen(tester, _Calls().view(), size: _tall);

      expect(
        find.text(
          r'Then $39.99 / year · Offer ends in 05:00',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('should mark only the selected plan', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        _Calls().view(selected: 'monthly'),
        size: _tall,
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Monthly plan')),
        isSemantics(hasCheckedState: true, isChecked: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Annual plan')),
        isSemantics(hasCheckedState: true, isChecked: false),
      );
      handle.dispose();
    });
  });

  group('PaywallView interaction', () {
    testWidgets('should report the tapped plan with a selection haptic', (
      tester,
    ) async {
      final calls = _Calls();
      final haptics = FakeHapticsService();
      await pumpScreen(tester, calls.view(), size: _tall, haptics: haptics);

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(calls.events, ['plan:monthly']);
      expect(haptics.events, [HapticKind.selection]);
    });

    testWidgets('should report a purchase with a light haptic', (tester) async {
      final calls = _Calls();
      final haptics = FakeHapticsService();
      await pumpScreen(tester, calls.view(), size: _tall, haptics: haptics);

      await tester.tap(find.text('Start 7-day free trial'));
      await tester.pumpAndSettle();

      expect(calls.events, ['purchase']);
      expect(haptics.events, [HapticKind.light]);
    });

    testWidgets('should report each exit separately', (tester) async {
      final calls = _Calls();
      await pumpScreen(tester, calls.view(), size: _tall);

      for (final label in [
        'I prefer inaccurate results',
        'Restore',
        'Terms',
        'Privacy',
      ]) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();

      expect(calls.events, ['decline', 'restore', 'terms', 'privacy', 'close']);
    });

    testWidgets('should report the system back gesture', (tester) async {
      final calls = _Calls();
      await pumpScreen(tester, calls.view(), size: _tall);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(calls.events, ['back']);
    });
  });

  group('PaywallView accessibility', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should meet tap target guidelines on $platform', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(
          tester,
          _Calls().view(),
          size: _tall,
          platform: platform,
        );

        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('should keep the close button reachable and 44 pixels wide', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, _Calls().view(), size: _tall);

      final size = tester.getSize(find.bySemanticsLabel('Close'));

      expect(size, const Size(44, 44));
      handle.dispose();
    });
  });

  group('PaywallView layout', () {
    const sizes = [
      Size(320, 568),
      Size(390, 844),
      Size(430, 932),
      Size(768, 1024),
    ];

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final size in sizes) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('should not overflow at $size, x$scale on $platform', (
            tester,
          ) async {
            await pumpScreen(
              tester,
              _Calls().view(),
              size: size,
              textScale: scale,
              platform: platform,
            );
            await tester.pump();

            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('should scroll when the content is taller than the screen', (
      tester,
    ) async {
      await pumpScreen(tester, _Calls().view(), size: const Size(320, 568));

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should pin the actions to the bottom on tall screens', (
      tester,
    ) async {
      await pumpScreen(tester, _Calls().view(), size: const Size(390, 1600));

      final footer = tester.getBottomLeft(find.text('Privacy'));

      expect(footer.dy, greaterThan(1500));
    });

    testWidgets('should cap the content width on wide screens', (tester) async {
      await pumpScreen(tester, _Calls().view(), size: const Size(1024, 1600));

      expect(tester.getSize(find.byType(SolennPrimaryButton)).width, 430);
    });
  });
}
