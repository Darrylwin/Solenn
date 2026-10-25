import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/components/solenn_primary_button.dart';
import 'package:solenn/core/design_system/components/solenn_sheet.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_row.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_view.dart';

import '../../../../helpers/fake_haptics_service.dart';
import '../../../../helpers/pump_screen.dart';

const List<CheckoutRow> _rows = [
  CheckoutRow(label: 'Free trial', value: '7 days'),
  CheckoutRow(label: 'Then', value: r'$39.99 / year'),
];

Widget _view({
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool processing = false,
}) {
  return Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CheckoutView(
        planName: 'Annual subscription',
        rows: _rows,
        dueToday: r'$0.00',
        processing: processing,
        onConfirmPressed: onConfirm ?? () {},
        onCancelPressed: onCancel ?? () {},
      ),
    ),
  );
}

void main() {
  group('CheckoutView content', () {
    testWidgets('should summarize the purchase', (tester) async {
      await pumpScreen(tester, _view());

      expect(find.text('Solenn Plus'), findsOneWidget);
      expect(find.text('Annual subscription'), findsOneWidget);
      expect(find.text('Free trial'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text(r'$39.99 / year'), findsOneWidget);
      expect(find.text('Due today'), findsOneWidget);
      expect(find.text(r'$0.00'), findsOneWidget);
      expect(find.textContaining('Renews automatically'), findsOneWidget);
    });

    testWidgets('should contain no text field', (tester) async {
      await pumpScreen(tester, _view());

      expect(find.byType(TextField), findsNothing);
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('should draw the amount due in the accent color', (
      tester,
    ) async {
      await pumpScreen(tester, _view());

      expect(
        tester.widget<Text>(find.text(r'$0.00')).style!.color,
        SolennColors.dark.accent,
      );
    });
  });

  group('CheckoutView interaction', () {
    testWidgets('should confirm with a medium haptic', (tester) async {
      var confirmed = 0;
      final haptics = FakeHapticsService();
      await pumpScreen(
        tester,
        _view(onConfirm: () => confirmed++),
        haptics: haptics,
      );

      await tester.tap(find.text('Confirm subscription'));
      await tester.pumpAndSettle();

      expect(confirmed, 1);
      expect(haptics.events, [HapticKind.medium]);
    });

    testWidgets('should cancel', (tester) async {
      var cancelled = 0;
      await pumpScreen(tester, _view(onCancel: () => cancelled++));

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelled, 1);
    });

    testWidgets('should block both actions while processing', (tester) async {
      var taps = 0;
      await pumpScreen(
        tester,
        _view(
          processing: true,
          onConfirm: () => taps++,
          onCancel: () => taps++,
        ),
      );

      await tester.tap(find.byType(SolennPrimaryButton));
      await tester.tap(find.text('Cancel'), warnIfMissed: false);
      await tester.pump();

      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('CheckoutView accessibility and layout', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should meet tap target guidelines on $platform', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, _view(), platform: platform);

        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('should not overflow with large text on $platform', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _view(),
          platform: platform,
          size: const Size(320, 568),
          textScale: 2,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('CheckoutView in a sheet', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should confirm from the sheet on $platform', (tester) async {
        var confirmed = 0;
        await pumpScreen(
          tester,
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showSolennSheet<void>(
                  context: context,
                  builder: (_) => SolennSheetScaffold(
                    child: CheckoutView(
                      planName: 'Annual subscription',
                      rows: _rows,
                      dueToday: r'$0.00',
                      onConfirmPressed: () => confirmed++,
                      onCancelPressed: () {},
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
          platform: platform,
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirm subscription'));
        await tester.pumpAndSettle();

        expect(confirmed, 1);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
