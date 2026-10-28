import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_page.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';

import '../../../../helpers/fake_clipboard_service.dart';
import '../../../../helpers/fake_haptics_service.dart';
import '../../../../helpers/pump_screen.dart';

const Map<String, String> _labels = {'/': '\u00F7', 'C': 'AC'};

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

String _result(WidgetTester tester) =>
    tester.widget<CalculatorDisplay>(find.byType(CalculatorDisplay)).result;

class _Harness {
  final FakeClipboardService clipboard = FakeClipboardService();
  final FakeHapticsService haptics = FakeHapticsService();

  Future<void> pump(WidgetTester tester) {
    return pumpScreen(
      tester,
      RepositoryProvider<SabotageEngine>.value(
        value: SabotageEngine(random: Random(1)),
        child: const CalculatorPage(),
      ),
      clipboard: clipboard,
      haptics: haptics,
    );
  }
}

Future<void> _longPressDisplay(WidgetTester tester) async {
  await tester.longPress(find.byType(CalculatorDisplay));
  await tester.pump();
}

/// Removes the page, which cancels the confirmation timer.
Future<void> _closePage(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

void main() {
  group('copy', () {
    testWidgets('should copy the number being typed', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '24000');

      await _longPressDisplay(tester);

      expect(harness.clipboard.copied, ['24,000']);
      await _closePage(tester);
    });

    testWidgets('should copy the displayed result, lie included', (
      tester,
    ) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '24000+220=');
      final shown = _result(tester);

      await _longPressDisplay(tester);

      expect(harness.clipboard.copied, [shown]);
      expect(shown, isNot('24,220'));
      await _closePage(tester);
    });

    testWidgets('should copy the percent sign as displayed', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '5%');

      await _longPressDisplay(tester);

      expect(harness.clipboard.copied, ['5%']);
      await _closePage(tester);
    });

    testWidgets('should give a medium haptic', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '5');
      final before = harness.haptics.events.length;

      await _longPressDisplay(tester);

      expect(harness.haptics.events.skip(before), [HapticKind.medium]);
      await _closePage(tester);
    });

    testWidgets('should copy nothing after an error', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '1/0=');
      final before = harness.haptics.events.length;

      await _longPressDisplay(tester);

      expect(harness.clipboard.copied, isEmpty);
      expect(harness.haptics.events.length, before);
      expect(find.text('Copied'), findsNothing);
    });
  });

  group('confirmation', () {
    testWidgets('should replace the caption, then bring it back', (
      tester,
    ) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '1+1=');
      expect(find.text('Verified · 99.9% accuracy'), findsOneWidget);

      await _longPressDisplay(tester);

      expect(find.text('Copied'), findsOneWidget);
      expect(find.text('Verified · 99.9% accuracy'), findsNothing);

      await tester.pump(calculatorCopiedDuration);
      await tester.pump();

      expect(find.text('Copied'), findsNothing);
      expect(find.text('Verified · 99.9% accuracy'), findsOneWidget);
    });

    testWidgets('should show while typing and then disappear', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '5');

      await _longPressDisplay(tester);
      expect(find.text('Copied'), findsOneWidget);

      await tester.pump(calculatorCopiedDuration);
      await tester.pump();

      expect(find.text('Copied'), findsNothing);
    });

    testWidgets('should restart its delay on a second copy', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '5');

      await _longPressDisplay(tester);
      await tester.pump(const Duration(milliseconds: 1000));
      await _longPressDisplay(tester);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('Copied'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Copied'), findsNothing);
      expect(harness.clipboard.copied, ['5', '5']);
    });

    testWidgets('should be cancelled when the page goes away', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await _type(tester, '5');
      await _longPressDisplay(tester);

      await _closePage(tester);
      await tester.pump(calculatorCopiedDuration);

      expect(tester.takeException(), isNull);
    });
  });

  group('debug overlay', () {
    testWidgets('should be hidden before any calculation', (tester) async {
      await _Harness().pump(tester);

      expect(find.textContaining('truth'), findsNothing);
    });

    testWidgets('should show the calculation, the strategy and the truth', (
      tester,
    ) async {
      await _Harness().pump(tester);

      await _type(tester, '1+1=');

      final label = tester
          .widgetList<Text>(find.textContaining('truth'))
          .single
          .data!;
      expect(
        label,
        matches(
          RegExp(r'^#1 \u00B7 (nearMissOffset|digitShuffle) \u00B7 truth 2$'),
        ),
      );
    });

    testWidgets('should count the calculations', (tester) async {
      await _Harness().pump(tester);

      await _type(tester, '1+1=C2+2=');

      expect(find.textContaining('#2'), findsOneWidget);
    });

    testWidgets('should disappear when the user types again', (tester) async {
      await _Harness().pump(tester);
      await _type(tester, '1+1=');

      await _type(tester, '+');

      expect(find.textContaining('truth'), findsNothing);
    });
  });
}
