import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_display.dart';

import '../../../../helpers/pump_screen.dart';

Widget _display({
  String? caption,
  String? debugLabel,
  VoidCallback? onLongPress,
}) {
  return Center(
    child: SizedBox(
      width: 342,
      height: 196,
      child: CalculatorDisplay(
        expression: '24,000 + 220',
        result: '24,820',
        caption: caption,
        debugLabel: debugLabel,
        onLongPress: onLongPress,
      ),
    ),
  );
}

void main() {
  group('content', () {
    testWidgets('should show the caption and the debug label together', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _display(caption: 'Verified', debugLabel: '#1 · digitShuffle'),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('#1 · digitShuffle'), findsOneWidget);
    });

    testWidgets('should show the debug label alone, at the end', (
      tester,
    ) async {
      await pumpScreen(tester, _display(debugLabel: '#1 · digitShuffle'));

      final card = tester.getRect(find.byType(CalculatorDisplay));
      final label = tester.getRect(find.text('#1 · digitShuffle'));

      expect(card.right - label.right, closeTo(24, 1));
    });

    testWidgets('should have no top line without caption or label', (
      tester,
    ) async {
      await pumpScreen(tester, _display());

      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('should not overflow when both lines are long', (tester) async {
      await pumpScreen(
        tester,
        _display(
          caption: 'Verified · 99.9% accuracy',
          debugLabel: '#12 · wrongOperator · truth 123,456,789',
        ),
        size: const Size(320, 568),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('long press', () {
    testWidgets('should call the callback', (tester) async {
      var presses = 0;
      await pumpScreen(tester, _display(onLongPress: () => presses++));

      await tester.longPress(find.byType(CalculatorDisplay));

      expect(presses, 1);
    });

    testWidgets('should do nothing without a callback', (tester) async {
      await pumpScreen(tester, _display());

      await tester.longPress(find.byType(CalculatorDisplay));

      expect(tester.takeException(), isNull);
    });

    testWidgets('should be offered to screen readers with a hint', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, _display(onLongPress: () {}));

      final data = tester
          .getSemantics(find.byType(CalculatorDisplay))
          .getSemanticsData();
      final overrides =
          [
            for (final id in data.customSemanticsActionIds ?? const <int>[])
              CustomSemanticsAction.getAction(id),
          ].whereType<CustomSemanticsAction>().where(
            (action) => action.action == SemanticsAction.longPress,
          );

      expect(data.hasAction(SemanticsAction.longPress), isTrue);
      expect(overrides.map((action) => action.hint), ['Copy result']);
      handle.dispose();
    });

    testWidgets('should not be offered without a callback', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, _display());

      final data = tester
          .getSemantics(find.byType(CalculatorDisplay))
          .getSemanticsData();

      expect(data.hasAction(SemanticsAction.longPress), isFalse);
      handle.dispose();
    });
  });
}
