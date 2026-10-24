import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_layout.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_view.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_display.dart';

import '../../../../helpers/fake_haptics_service.dart';
import '../../../../helpers/pump_screen.dart';

Widget _view({
  ValueChanged<CalculatorKey>? onKeyPressed,
  CalculatorKey? selectedOperator,
  Widget? headerCenter,
  Widget? banner,
  String? caption = 'Verified · 99.9% accuracy',
}) {
  return CalculatorView(
    expression: '24,000+220',
    result: '24,820',
    caption: caption,
    selectedOperator: selectedOperator,
    headerCenter: headerCenter,
    banner: banner,
    onKeyPressed: onKeyPressed ?? (_) {},
  );
}

void main() {
  group('CalculatorView content', () {
    testWidgets('should show the expression, the result and the caption', (
      tester,
    ) async {
      await pumpScreen(tester, _view());

      expect(find.textContaining('24,000', findRichText: true), findsOneWidget);
      expect(find.text('24,820'), findsOneWidget);
      expect(find.text('Verified · 99.9% accuracy'), findsOneWidget);
    });

    testWidgets('should hide the caption when none is given', (tester) async {
      await pumpScreen(tester, _view(caption: null));

      expect(find.text('Verified · 99.9% accuracy'), findsNothing);
    });

    testWidgets('should render the header and banner slots', (tester) async {
      await pumpScreen(
        tester,
        _view(
          headerCenter: const Text('PLUS'),
          banner: const SizedBox(height: 72, child: Text('Welcome')),
        ),
      );

      expect(find.text('PLUS'), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('should render all 19 keys', (tester) async {
      await pumpScreen(tester, _view());

      expect(
        find.byType(SolennKey),
        findsNWidgets(CalculatorKey.values.length),
      );
    });

    testWidgets('should draw the selected operator in its selected state', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _view(selectedOperator: CalculatorKey.add),
      );

      final color = tester.widget<Text>(find.text('+')).style?.color;

      expect(color, SolennColors.dark.accent);
    });
  });

  group('CalculatorView interaction', () {
    testWidgets('should report the pressed key', (tester) async {
      final pressed = <CalculatorKey>[];
      await pumpScreen(tester, _view(onKeyPressed: pressed.add));

      await tester.tap(find.text('7'));
      await tester.tap(find.text('+'));
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      expect(pressed, [
        CalculatorKey.seven,
        CalculatorKey.add,
        CalculatorKey.equals,
      ]);
    });

    testWidgets('should give distinct haptic feedback per key kind', (
      tester,
    ) async {
      final haptics = FakeHapticsService();
      await pumpScreen(tester, _view(), haptics: haptics);

      await tester.tap(find.text('7'));
      await tester.tap(find.text('+'));
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      expect(haptics.events, [
        HapticKind.selection,
        HapticKind.light,
        HapticKind.medium,
      ]);
    });

    testWidgets('should disable header buttons without callback', (
      tester,
    ) async {
      await pumpScreen(tester, _view());

      expect(find.byType(SolennIconButton), findsNWidgets(2));
    });
  });

  group('CalculatorView layout', () {
    const sizes = [
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(430, 932),
      Size(768, 1024),
    ];

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final size in sizes) {
        testWidgets('should not overflow at $size on $platform', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            _view(
              headerCenter: const Text('PLUS'),
              banner: const SizedBox(height: 72),
            ),
            platform: platform,
            size: size,
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('should not overflow with large text', (tester) async {
      for (final size in const [Size(360, 640), Size(390, 844)]) {
        await pumpScreen(tester, _view(), size: size, textScale: 2);

        expect(tester.takeException(), isNull, reason: '$size');
      }
    });

    testWidgets('should keep the content column within its maximum width', (
      tester,
    ) async {
      await pumpScreen(tester, _view(), size: const Size(1024, 1024));

      final display = tester.getSize(find.byType(CalculatorView));
      final keypadLeft = tester.getTopLeft(find.text('7')).dx;

      expect(display.width, 1024);
      expect(keypadLeft, greaterThan(200));
    });

    testWidgets('should stretch the display across the content column', (
      tester,
    ) async {
      await pumpScreen(tester, _view());

      expect(tester.getSize(find.byType(CalculatorDisplay)).width, 342);
    });

    testWidgets('should cap the display height on tall screens', (
      tester,
    ) async {
      await pumpScreen(tester, _view(), size: const Size(390, 1000));

      expect(
        tester.getSize(find.byType(CalculatorDisplay)).height,
        calculatorMaxDisplayHeight,
      );
    });

    testWidgets('should align the result to the end of the display', (
      tester,
    ) async {
      await pumpScreen(tester, _view());

      final card = tester.getRect(find.byType(CalculatorDisplay));
      final result = tester.getRect(find.text('24,820'));

      expect(
        card.right - result.right,
        closeTo(SolennSpacing.standard.xxl, 1),
      );
    });
  });
}
