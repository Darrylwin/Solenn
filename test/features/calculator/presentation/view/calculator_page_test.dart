import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/presentation/history/history_view.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_page.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';

import '../../../../helpers/pump_screen.dart';

const Map<String, String> _labels = {
  '/': '\u00F7',
  '*': '\u00D7',
  '-': '\u2212',
  'C': 'AC',
};

const String _caption = 'Verified · 99.9% accuracy';

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

CalculatorDisplay _display(WidgetTester tester) =>
    tester.widget<CalculatorDisplay>(find.byType(CalculatorDisplay));

Future<void> _pumpPage(
  WidgetTester tester, {
  TargetPlatform platform = TargetPlatform.android,
  Size size = const Size(390, 844),
  double textScale = 1,
}) {
  return pumpScreen(
    tester,
    RepositoryProvider<SabotageEngine>.value(
      value: SabotageEngine(random: Random(1)),
      child: const CalculatorPage(),
    ),
    platform: platform,
    size: size,
    textScale: textScale,
  );
}

Future<void> _openHistory(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.history_rounded));
  await tester.pumpAndSettle();
}

void main() {
  final aNumber = RegExp(r'^\d[\d,]*(\.\d+)?$');

  group('display', () {
    testWidgets('should start at zero without caption', (tester) async {
      await _pumpPage(tester);

      expect(_display(tester).result, '0');
      expect(_display(tester).expression, '');
      expect(_display(tester).caption, isNull);
    });

    testWidgets('should show the number being typed', (tester) async {
      await _pumpPage(tester);

      await _type(tester, '24000');

      expect(_display(tester).result, '24,000');
    });

    testWidgets('should show the pending operation', (tester) async {
      await _pumpPage(tester);

      await _type(tester, '24000+');

      expect(_display(tester).expression, '24,000 +');
      expect(_display(tester).result, '24,000');
    });

    testWidgets('should show a wrong result with its caption', (tester) async {
      await _pumpPage(tester);

      await _type(tester, '24000+220=');

      expect(_display(tester).expression, '24,000 + 220');
      expect(_display(tester).result, matches(aNumber));
      expect(_display(tester).result, isNot('24,220'));
      expect(_display(tester).caption, _caption);
    });

    testWidgets('should repeat the same lie for the same expression', (
      tester,
    ) async {
      await _pumpPage(tester);

      await _type(tester, '1+1=');
      final first = _display(tester).result;
      await _type(tester, 'C1+1=');

      expect(_display(tester).result, first);
    });

    testWidgets('should continue from the displayed result', (tester) async {
      await _pumpPage(tester);

      await _type(tester, '1+1=');
      final shown = _display(tester).result;
      await _type(tester, '+');

      expect(_display(tester).expression, '$shown +');
    });

    testWidgets('should show an error for a division by zero', (tester) async {
      await _pumpPage(tester);

      await _type(tester, '1/0=');

      expect(_display(tester).result, 'Error');
      expect(_display(tester).caption, isNull);
    });

    testWidgets('should start over with a digit after an error', (
      tester,
    ) async {
      await _pumpPage(tester);

      await _type(tester, '1/0=5');

      expect(_display(tester).result, '5');
      expect(_display(tester).expression, '');
    });

    testWidgets('should reset with AC', (tester) async {
      await _pumpPage(tester);

      await _type(tester, '5+3C');

      expect(_display(tester).result, '0');
      expect(_display(tester).expression, '');
    });
  });

  group('operator key', () {
    testWidgets('should be drawn selected while it awaits an operand', (
      tester,
    ) async {
      await _pumpPage(tester);
      await _type(tester, '5');
      expect(
        tester.widget<Text>(_key('+')).style?.color,
        SolennColors.dark.onAccent,
      );

      await _type(tester, '+');

      expect(
        tester.widget<Text>(_key('+')).style?.color,
        SolennColors.dark.accent,
      );
    });
  });

  group('history', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should be empty before any calculation on $platform', (
        tester,
      ) async {
        await _pumpPage(tester, platform: platform);

        await _openHistory(tester);

        expect(find.text('No calculations yet'), findsOneWidget);
      });

      testWidgets(
        'should list a calculation as it was displayed on $platform',
        (tester) async {
          await _pumpPage(tester, platform: platform);
          await _type(tester, '24000+220=');
          final result = _display(tester).result;

          await _openHistory(tester);

          Finder inHistory(Finder matching) =>
              find.descendant(of: find.byType(HistoryView), matching: matching);
          expect(
            inHistory(find.text('24,000 + 220', findRichText: true)),
            findsOneWidget,
          );
          expect(inHistory(find.text(result)), findsOneWidget);
        },
      );

      testWidgets('should be cleared from the sheet on $platform', (
        tester,
      ) async {
        await _pumpPage(tester, platform: platform);
        await _type(tester, '1+1=');
        await _openHistory(tester);

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();

        expect(find.text('No calculations yet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('should keep the calculator result after clearing', (
      tester,
    ) async {
      await _pumpPage(tester);
      await _type(tester, '1+1=');
      final result = _display(tester).result;
      await _openHistory(tester);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(_display(tester).result, result);
    });
  });

  group('rebuilds', () {
    testWidgets('should not rebuild the keys while typing', (tester) async {
      await _pumpPage(tester);
      var rebuilt = 0;
      final previous = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (element, builtOnce) {
        if (element.widget is SolennKey) rebuilt++;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = previous);

      await _type(tester, '2400');

      expect(rebuilt, 0);
    });

    testWidgets('should redraw the keys when the pending operator changes', (
      tester,
    ) async {
      await _pumpPage(tester);
      await _type(tester, '5');
      var rebuilt = 0;
      final previous = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (element, builtOnce) {
        if (element.widget is SolennKey) rebuilt++;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = previous);

      await _type(tester, '+');

      expect(rebuilt, greaterThan(0));
    });
  });

  group('accessibility and layout', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should meet guidelines on $platform', (tester) async {
        final handle = tester.ensureSemantics();
        await _pumpPage(tester, platform: platform);
        await _type(tester, '1+1=');

        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    const sizes = [Size(320, 568), Size(390, 844), Size(768, 1024)];
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final size in sizes) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('should not overflow at $size, x$scale on $platform', (
            tester,
          ) async {
            await _pumpPage(
              tester,
              platform: platform,
              size: size,
              textScale: scale,
            );
            await _type(tester, '24000+220=');
            await _openHistory(tester);

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
