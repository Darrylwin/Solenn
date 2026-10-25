import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_fine_print.dart';

import '../../../../helpers/pump_screen.dart';

const String _text = r'Then $39.99 / year';

Finder _line(String countdown) => find.text(
  '$_text · Offer ends in $countdown',
  findRichText: true,
);

Widget _finePrint({Duration offerDuration = paywallOfferDuration}) => Center(
  child: PaywallFinePrint(text: _text, offerDuration: offerDuration),
);

void main() {
  group('formatCountdown', () {
    test('should format minutes and seconds with two digits', () {
      expect(formatCountdown(const Duration(minutes: 5)), '05:00');
      expect(formatCountdown(const Duration(minutes: 4, seconds: 59)), '04:59');
      expect(formatCountdown(const Duration(seconds: 7)), '00:07');
    });

    test('should clamp a negative duration to zero', () {
      expect(formatCountdown(const Duration(seconds: -3)), '00:00');
    });
  });

  group('PaywallFinePrint', () {
    testWidgets('should start from the full offer duration', (tester) async {
      await pumpScreen(tester, _finePrint());

      expect(_line('05:00'), findsOneWidget);
    });

    testWidgets('should count down every second', (tester) async {
      await pumpScreen(tester, _finePrint());

      await tester.pump(const Duration(seconds: 1));
      expect(_line('04:59'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(_line('04:57'), findsOneWidget);
    });

    testWidgets('should restart instead of reaching zero', (tester) async {
      await pumpScreen(
        tester,
        _finePrint(offerDuration: const Duration(seconds: 3)),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(_line('00:02'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(_line('00:01'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(_line('00:03'), findsOneWidget);
    });

    testWidgets('should stop ticking once removed', (tester) async {
      await pumpScreen(tester, _finePrint());
      await tester.pumpWidget(const SizedBox());

      await tester.pump(const Duration(seconds: 5));

      expect(tester.takeException(), isNull);
    });
  });
}
