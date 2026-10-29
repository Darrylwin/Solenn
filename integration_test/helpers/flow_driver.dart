import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/app.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:solenn/features/subscription/domain/flow/subscription_timings.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';

import '../../test/helpers/test_dependencies.dart';

/// Delays of the flows: short enough to keep the run fast, long enough for
/// the engine to render each step.
const SubscriptionTimings flowTimings = SubscriptionTimings(
  paywallDelay: Duration(milliseconds: 300),
  processingDelay: Duration(milliseconds: 300),
);

// Real time passes in an integration test: leave room after a delay.
const Duration _margin = Duration(milliseconds: 300);

const Map<String, String> _labels = {
  '/': '\u00F7',
  '*': '\u00D7',
  '-': '\u2212',
  'C': 'AC',
};

Finder _key(String label) => find.descendant(
  of: find.byType(CalculatorKeypad),
  matching: find.text(label),
);

/// Starts the application with the short delays of [flowTimings].
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    SolennApp(dependencies: buildTestDependencies(timings: flowTimings)),
  );
  await tester.pumpAndSettle();
}

/// Presses the keys of [keys], one character per key.
Future<void> type(WidgetTester tester, String keys) async {
  for (final character in keys.split('')) {
    await tester.tap(_key(_labels[character] ?? character));
    await tester.pump();
  }
}

/// Taps [finder], scrolling it into view first.
///
/// Screens such as the paywall scroll on small devices, so a widget can be
/// built but out of reach.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Waits for the paywall delay of [flowTimings] to elapse, and for the screen
/// to settle.
Future<void> waitPastPaywallDelay(WidgetTester tester) async {
  await tester.pump(flowTimings.paywallDelay + _margin);
  await tester.pumpAndSettle();
}

/// Types [keys], a first calculation, and waits for the paywall.
Future<void> reachPaywall(
  WidgetTester tester, {
  String keys = '1+1=',
}) async {
  await type(tester, keys);
  await waitPastPaywallDelay(tester);
  expect(find.byType(PaywallView), findsOneWidget);
}

/// Checks that the app is unlocked: no paywall, and the PLUS badge.
void expectUnlocked() {
  expect(find.byType(PaywallView), findsNothing);
  expect(find.text('PLUS'), findsOneWidget);
}
