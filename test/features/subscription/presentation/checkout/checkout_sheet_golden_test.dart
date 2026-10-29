@Tags(<String>['golden'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_row.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_view.dart';

import '../../../../helpers/golden_helpers.dart';
import '../../../../helpers/load_app_fonts.dart';
import '../../../../helpers/pump_screen.dart';

typedef _Purchase = ({
  String planName,
  List<CheckoutRow> rows,
  String dueToday,
});

const _Purchase _annual = (
  planName: 'Annual subscription',
  rows: [
    CheckoutRow(label: 'Free trial', value: '7 days'),
    CheckoutRow(label: 'Then', value: r'$39.99 / year'),
  ],
  dueToday: r'$0.00',
);

const _Purchase _monthly = (
  planName: 'Monthly subscription',
  rows: [CheckoutRow(label: 'Price', value: r'$4.99 / month')],
  dueToday: r'$4.99',
);

Future<void> _openSheet(
  WidgetTester tester, {
  required _Purchase purchase,
  required Size size,
  required TargetPlatform platform,
}) async {
  late BuildContext context;
  await pumpScreen(
    tester,
    Builder(
      builder: (inner) {
        context = inner;
        return const SizedBox.expand();
      },
    ),
    platform: platform,
    size: size,
  );

  unawaited(
    showSolennSheet<void>(
      context: context,
      builder: (_) => SolennSheetScaffold(
        child: CheckoutView(
          planName: purchase.planName,
          rows: purchase.rows,
          dueToday: purchase.dueToday,
          onConfirmPressed: () {},
          onCancelPressed: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final width in goldenWidths) {
    testWidgets('should match the golden of the annual sheet at $width', (
      tester,
    ) async {
      await _openSheet(
        tester,
        purchase: _annual,
        size: phoneSize(width),
        platform: TargetPlatform.android,
      );

      await expectScreenGolden(
        goldenName('checkout-annual', width, platform: TargetPlatform.android),
      );
    });
  }

  testWidgets('should match the golden of the annual sheet on iOS', (
    tester,
  ) async {
    await _openSheet(
      tester,
      purchase: _annual,
      size: phoneSize(390),
      platform: TargetPlatform.iOS,
    );

    await expectScreenGolden(
      goldenName('checkout-annual', 390, platform: TargetPlatform.iOS),
    );
  });

  testWidgets('should match the golden of the monthly sheet', (tester) async {
    await _openSheet(
      tester,
      purchase: _monthly,
      size: phoneSize(390),
      platform: TargetPlatform.android,
    );

    await expectScreenGolden(
      goldenName('checkout-monthly', 390, platform: TargetPlatform.android),
    );
  });
}
