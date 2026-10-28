import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/app.dart';
import 'package:solenn/app/home_screen.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/account/presentation/account/account_view.dart';
import 'package:solenn/features/account/presentation/legal/legal_page.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';

import '../helpers/test_dependencies.dart';

const Duration _paywallDelay = Duration(milliseconds: 2500);
const Duration _transition = Duration(milliseconds: 500);

Finder _key(String label) => find.descendant(
  of: find.byType(CalculatorKeypad),
  matching: find.text(label),
);

Future<void> _type(WidgetTester tester, String keys) async {
  for (final character in keys.split('')) {
    await tester.tap(_key(character));
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

Future<void> _openAccount(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.person_outline_rounded));
  await tester.pump();
  await tester.pump(_transition);
}

Future<void> _reachPaywall(WidgetTester tester) async {
  await _type(tester, '1+1=');
  await tester.pump(_paywallDelay);
  await tester.pump(_transition);
}

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(_transition);
}

void main() {
  group('opening the account', () {
    testWidgets('should show the free plan and the version', (tester) async {
      await _pumpApp(tester);

      await _openAccount(tester);

      expect(find.byType(AccountView), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Solenn Free'), findsOneWidget);
      expect(find.text('Standard accuracy'), findsOneWidget);
      expect(find.text('0.0.0 (0)'), findsOneWidget);
      expect(find.byType(SolennChip), findsNothing);
    });

    testWidgets('should go back with the back button', (tester) async {
      await _pumpApp(tester);
      await _openAccount(tester);

      await _tapAndSettle(tester, find.byType(SolennBackButton));

      expect(find.byType(AccountView), findsNothing);
      expect(find.byType(CalculatorKeypad), findsOneWidget);
    });

    testWidgets('should go back with the system back', (tester) async {
      await _pumpApp(tester);
      await _openAccount(tester);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(_transition);

      expect(find.byType(AccountView), findsNothing);
      expect(find.byType(CalculatorKeypad), findsOneWidget);
    });
  });

  group('the plan', () {
    testWidgets('should read Plus once the paywall was dismissed', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);
      await _tapAndSettle(tester, find.byIcon(Icons.close_rounded));

      await _openAccount(tester);

      expect(find.text('Solenn Plus'), findsOneWidget);
      expect(find.text('Complimentary access'), findsOneWidget);
      expect(find.text('PLUS'), findsOneWidget);
    });
  });

  group('restoring purchases', () {
    testWidgets('should unlock and return to the calculator', (tester) async {
      await _pumpApp(tester);
      await _openAccount(tester);

      await _tapAndSettle(tester, find.text('Restore purchases'));

      expect(_state(tester), const Active(Restored()));
      expect(find.byType(AccountView), findsNothing);
      expect(find.text('PLUS'), findsOneWidget);
      expect(find.text('Welcome to Solenn Plus'), findsOneWidget);
    });
  });

  group('the legal pages', () {
    testWidgets('should open the terms from the account and come back', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _openAccount(tester);

      await _tapAndSettle(tester, find.text('Terms of Service'));
      expect(find.byType(LegalPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(_transition);

      expect(find.byType(LegalPage), findsNothing);
      expect(find.byType(AccountView), findsOneWidget);
    });

    testWidgets('should open the privacy policy from the account', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _openAccount(tester);

      await _tapAndSettle(tester, find.text('Privacy Policy'));

      expect(find.byType(LegalPage), findsOneWidget);
    });

    testWidgets('should open the terms from the paywall and come back', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      await _tapAndSettle(tester, find.text('Terms'));
      expect(find.byType(LegalPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(_transition);

      expect(find.byType(LegalPage), findsNothing);
      expect(find.byType(PaywallView), findsOneWidget);
      expect(_state(tester), isA<PaywallVisible>());
    });

    testWidgets('should open the privacy policy from the paywall', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _reachPaywall(tester);

      await _tapAndSettle(tester, find.text('Privacy'));

      expect(find.byType(LegalPage), findsOneWidget);
    });
  });

  testWidgets('should open the licenses page', (tester) async {
    LicenseRegistry.reset();
    addTearDown(LicenseRegistry.reset);
    await _pumpApp(tester);
    await _openAccount(tester);

    await _tapAndSettle(tester, find.text('Open-source licenses'));

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
