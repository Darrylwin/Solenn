import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/app.dart';
import 'package:solenn/app/home_screen.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_page.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';

import '../helpers/test_dependencies.dart';

const Duration _paywallDelay = Duration(milliseconds: 2500);
const Duration _processing = Duration(milliseconds: 1200);
const Duration _transition = Duration(milliseconds: 500);
const Map<String, String> _labels = {'/': '\u00F7', 'C': 'AC'};
const TargetPlatformVariant _bothPlatforms = TargetPlatformVariant({
  TargetPlatform.android,
  TargetPlatform.iOS,
});

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

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(SolennApp(dependencies: buildTestDependencies()));
  await tester.pump();
}

SubscriptionState _state(WidgetTester tester) => tester
    .element(find.byType(HomeScreen, skipOffstage: false))
    .read<SubscriptionCubit>()
    .state;

/// Types a first calculation and waits for the paywall.
Future<void> _reachPaywall(WidgetTester tester) async {
  await _type(tester, '1+1=');
  await tester.pump(_paywallDelay);
  await tester.pump(_transition);
}

Future<void> _openCheckout(WidgetTester tester) async {
  await _reachPaywall(tester);
  await tester.tap(find.text('Start 7-day free trial'));
  await tester.pump();
  await tester.pump(_transition);
}

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(_transition);
}

/// Sends the system back and lets the resulting transition finish.
Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pump();
  await tester.pump();
  await tester.pump(_transition);
}

void _expectUnlocked(WidgetTester tester) {
  expect(_state(tester), isA<Active>());
  expect(find.byType(PaywallView), findsNothing);
  expect(find.text('Confirm subscription'), findsNothing);
  expect(find.text('PLUS'), findsOneWidget);
}

void main() {
  group('the wait', () {
    testWidgets('should not show the paywall before a calculation', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.pump(const Duration(minutes: 1));

      expect(find.byType(PaywallView), findsNothing);
      expect(_state(tester), const Locked());
    });

    testWidgets('should keep the first result alone for 2.5 seconds', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _type(tester, '1+1=');

      await tester.pump(_paywallDelay - const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.byType(PaywallView), findsNothing);
      expect(find.text('Verified · 99.9% accuracy'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(_transition);
      expect(find.byType(PaywallView), findsOneWidget);
    });

    testWidgets('should show the paywall only once', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);
      await _tapAndSettle(tester, find.byIcon(Icons.close_rounded));

      await _type(tester, 'C2+2=');
      await tester.pump(const Duration(seconds: 10));

      expect(find.byType(PaywallView), findsNothing);
    });

    testWidgets('should not show a paywall for an error', (tester) async {
      await _pumpApp(tester);

      await _type(tester, '1/0=');
      await tester.pump(const Duration(seconds: 10));

      expect(find.byType(PaywallView), findsNothing);
      expect(_state(tester), const Locked());
    });
  });

  group('leaving the paywall', () {
    testWidgets('should unlock with the close button', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      await _tapAndSettle(tester, find.byIcon(Icons.close_rounded));

      _expectUnlocked(tester);
      expect(
        _state(tester),
        const Active(Dismissed(DismissReason.closeButton)),
      );
    });

    testWidgets('should unlock with the decline link', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      await _tapAndSettle(tester, find.text('I prefer inaccurate results'));

      _expectUnlocked(tester);
    });

    testWidgets('should unlock with the system back', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      await _systemBack(tester);

      _expectUnlocked(tester);
      expect(
        _state(tester),
        const Active(Dismissed(DismissReason.systemBack)),
      );
    });

    testWidgets('should unlock by restoring purchases', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      await _tapAndSettle(tester, find.text('Restore'));

      _expectUnlocked(tester);
      expect(_state(tester), const Active(Restored()));
    });

    testWidgets('should let the user keep calculating', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);
      await _tapAndSettle(tester, find.byIcon(Icons.close_rounded));

      await _type(tester, 'C2+3=');

      expect(find.text('Verified · 99.9% accuracy'), findsOneWidget);
    });
  });

  group('the welcome banner', () {
    testWidgets('should show for four seconds, the badge staying', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);
      await _tapAndSettle(tester, find.byIcon(Icons.close_rounded));
      expect(find.text('Welcome to Solenn Plus'), findsOneWidget);

      await tester.pump(
        welcomeBannerDuration - _transition - const Duration(milliseconds: 100),
      );
      expect(find.text('Welcome to Solenn Plus'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(_transition);
      expect(find.text('Welcome to Solenn Plus'), findsNothing);
      expect(find.text('PLUS'), findsOneWidget);
    });

    testWidgets('should not show before the app is unlocked', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      expect(find.text('Welcome to Solenn Plus'), findsNothing);
      expect(find.text('PLUS'), findsNothing);
    });
  });

  group('a purchase', () {
    testWidgets(
      'should confirm, process and unlock',
      (tester) async {
        await _pumpApp(tester);
        await _openCheckout(tester);
        expect(find.text('Annual subscription'), findsOneWidget);
        expect(
          _state(tester),
          const CheckoutVisible(plan: SubscriptionPlan.annual),
        );

        await tester.tap(find.text('Confirm subscription'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(_state(tester), const Processing(plan: SubscriptionPlan.annual));

        await tester.pump(_processing);
        await tester.pump(_transition);

        _expectUnlocked(tester);
        expect(
          _state(tester),
          const Active(Purchased(SubscriptionPlan.annual)),
        );
      },
      variant: _bothPlatforms,
    );

    testWidgets('should buy the plan that was selected', (tester) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      await tester.tap(find.text('Monthly'));
      await tester.pump();
      await _tapAndSettle(tester, find.text(r'Subscribe for $4.99 / month'));

      expect(find.text('Monthly subscription'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CheckoutPage),
          matching: find.text(r'$4.99'),
        ),
        findsOneWidget,
      );
      expect(
        _state(tester),
        const CheckoutVisible(plan: SubscriptionPlan.monthly),
      );
    });
  });

  group('cancelling a purchase', () {
    testWidgets('should return to the paywall with the same selection', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);
      await tester.tap(find.text('Monthly'));
      await tester.pump();
      await _tapAndSettle(tester, find.text(r'Subscribe for $4.99 / month'));

      await _tapAndSettle(tester, find.text('Cancel'));

      expect(find.text('Confirm subscription'), findsNothing);
      expect(find.byType(PaywallView), findsOneWidget);
      expect(
        _state(tester),
        const PaywallVisible(selectedPlan: SubscriptionPlan.monthly),
      );
    });

    testWidgets('should allow buying again afterwards', (tester) async {
      await _pumpApp(tester);
      await _openCheckout(tester);
      await _tapAndSettle(tester, find.text('Cancel'));

      await _tapAndSettle(tester, find.text('Start 7-day free trial'));

      expect(find.text('Confirm subscription'), findsOneWidget);
    });

    testWidgets('should treat the system back as a cancellation', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _openCheckout(tester);

      await _systemBack(tester);

      expect(find.text('Confirm subscription'), findsNothing);
      expect(find.byType(PaywallView), findsOneWidget);
      expect(_state(tester), isA<PaywallVisible>());
    });

    testWidgets('should ignore the system back while processing', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _openCheckout(tester);
      await tester.tap(find.text('Confirm subscription'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Confirm subscription'), findsOneWidget);
      expect(_state(tester), isA<Processing>());

      await tester.pump(_processing);
      await tester.pump(_transition);
      _expectUnlocked(tester);
    });
  });
}
