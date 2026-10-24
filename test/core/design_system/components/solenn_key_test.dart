import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

Widget _key({
  VoidCallback? onPressed,
  VoidCallback? onPressStart,
  SolennKeyVariant variant = SolennKeyVariant.digit,
  bool selected = false,
  String? label = '7',
  IconData? icon,
}) {
  return Center(
    child: SizedBox.square(
      dimension: 76,
      child: SolennKey(
        variant: variant,
        label: label,
        icon: icon,
        semanticLabel: 'Seven',
        selected: selected,
        onPressed: onPressed,
        onPressStart: onPressStart,
      ),
    ),
  );
}

Color? _overlayColor(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(SolennKey),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return (container.decoration! as ShapeDecoration).color;
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    group('SolennKey on $platform', () {
      testWidgets('should report the press start before the press', (
        tester,
      ) async {
        final events = <String>[];
        await pumpScreen(
          tester,
          _key(
            onPressStart: () => events.add('start'),
            onPressed: () => events.add('pressed'),
          ),
          platform: platform,
        );

        await tester.tap(find.byType(SolennKey));
        await tester.pumpAndSettle();

        expect(events, ['start', 'pressed']);
      });

      testWidgets('should ignore taps when disabled', (tester) async {
        var started = false;
        await pumpScreen(
          tester,
          _key(onPressStart: () => started = true),
          platform: platform,
        );

        await tester.tap(find.byType(SolennKey));
        await tester.pumpAndSettle();

        expect(started, isFalse);
      });

      testWidgets('should expose its label and meet tap target guidelines', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, _key(onPressed: () {}), platform: platform);

        expect(find.bySemanticsLabel('Seven'), findsOneWidget);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('should draw an icon when no label is given', (tester) async {
        await pumpScreen(
          tester,
          _key(label: null, icon: Icons.backspace_outlined, onPressed: () {}),
          platform: platform,
        );

        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      });
    });
  }

  group('SolennKey colors', () {
    const colors = SolennColors.dark;

    Color? labelColor(WidgetTester tester) =>
        tester.widget<Text>(find.text('7')).style?.color;

    testWidgets('should use the primary text color on dark keys', (
      tester,
    ) async {
      await pumpScreen(tester, _key(onPressed: () {}));

      expect(labelColor(tester), colors.textPrimary);
    });

    testWidgets('should use the dark content color on accent keys', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _key(variant: SolennKeyVariant.accent, onPressed: () {}),
      );

      expect(labelColor(tester), colors.onAccent);
    });

    testWidgets('should invert accent keys when selected', (tester) async {
      await pumpScreen(
        tester,
        _key(
          variant: SolennKeyVariant.accent,
          selected: true,
          onPressed: () {},
        ),
      );

      expect(labelColor(tester), colors.accent);
    });
  });

  group('SolennKey press feedback on iOS', () {
    testWidgets('should brighten while pressed and restore on release', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _key(onPressed: () {}),
        platform: TargetPlatform.iOS,
      );
      expect(_overlayColor(tester), Colors.transparent);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SolennKey)),
      );
      await tester.pump(SolennMotion.defaults.press);
      expect(_overlayColor(tester), isNot(Colors.transparent));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_overlayColor(tester), Colors.transparent);
    });
  });
}
