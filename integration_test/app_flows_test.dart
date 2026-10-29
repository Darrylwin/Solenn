import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solenn/features/account/presentation/account/account_view.dart';
import 'package:solenn/features/calculator/presentation/history/history_view.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';

import 'helpers/flow_driver.dart';

const String _caption = 'Verified · 99.9% accuracy';

String _displayedResult(WidgetTester tester) =>
    tester.widget<CalculatorDisplay>(find.byType(CalculatorDisplay)).result;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('flow 1: a purchase', () {
    testWidgets('should unlock Plus when the annual plan is confirmed', (
      tester,
    ) async {
      await pumpApp(tester);

      await type(tester, '1+1=');
      await tester.pump();
      expect(find.text(_caption), findsOneWidget);

      await waitPastPaywallDelay(tester);
      expect(find.byType(PaywallView), findsOneWidget);
      expect(find.text('Start 7-day free trial'), findsOneWidget);

      await tapVisible(tester, find.text('Start 7-day free trial'));
      expect(find.text('Annual subscription'), findsOneWidget);

      await tapVisible(tester, find.text('Confirm subscription'));

      expectUnlocked();
      expect(find.text('Confirm subscription'), findsNothing);
      expect(find.text('Welcome to Solenn Plus'), findsOneWidget);
    });
  });

  group('flow 2: the close button', () {
    testWidgets('should unlock and keep the calculator when the paywall is '
        'closed', (tester) async {
      await pumpApp(tester);
      await reachPaywall(tester);

      await tapVisible(tester, find.byIcon(Icons.close_rounded));

      expectUnlocked();
      expect(find.byType(CalculatorKeypad), findsOneWidget);
    });
  });

  group('flow 3: the system back', () {
    testWidgets('should unlock when the paywall is dismissed with the back '
        'gesture', (tester) async {
      await pumpApp(tester);
      await reachPaywall(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expectUnlocked();
      expect(find.byType(CalculatorKeypad), findsOneWidget);
    });
  });

  group('flow 4: restoring from the account', () {
    testWidgets('should unlock before any calculation, for good', (
      tester,
    ) async {
      await pumpApp(tester);

      await tapVisible(tester, find.byIcon(Icons.person_outline_rounded));
      expect(find.byType(AccountView), findsOneWidget);
      expect(find.text('Solenn Free'), findsOneWidget);

      await tapVisible(tester, find.text('Restore purchases'));

      expectUnlocked();
      expect(find.byType(AccountView), findsNothing);
      expect(find.text('Welcome to Solenn Plus'), findsOneWidget);

      await type(tester, '1+1=');
      await waitPastPaywallDelay(tester);

      expect(find.byType(PaywallView), findsNothing);
      expect(find.text(_caption), findsOneWidget);
    });
  });

  group('flow 5: the history', () {
    testWidgets('should list the displayed result, never the truth', (
      tester,
    ) async {
      await pumpApp(tester);
      await reachPaywall(tester, keys: '24000+220=');
      final displayed = _displayedResult(tester);
      expect(displayed, isNot('24,220'));
      await tapVisible(tester, find.byIcon(Icons.close_rounded));

      await tapVisible(tester, find.byIcon(Icons.history_rounded));

      Finder inHistory(Finder matching) =>
          find.descendant(of: find.byType(HistoryView), matching: matching);
      expect(
        inHistory(find.text('24,000 + 220', findRichText: true)),
        findsOneWidget,
      );
      expect(inHistory(find.text(displayed)), findsOneWidget);
      expect(inHistory(find.text('24,220')), findsNothing);
    });
  });

  group('flow 6: the paywall appears once', () {
    testWidgets('should not reopen the paywall at a later calculation', (
      tester,
    ) async {
      await pumpApp(tester);
      await reachPaywall(tester);
      await tapVisible(tester, find.byIcon(Icons.close_rounded));

      await type(tester, 'C2+2=');
      await waitPastPaywallDelay(tester);

      expect(find.byType(PaywallView), findsNothing);
      expect(find.text(_caption), findsOneWidget);
    });
  });
}
