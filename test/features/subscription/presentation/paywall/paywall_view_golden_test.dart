@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_plan_option.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';

import '../../../../helpers/golden_helpers.dart';
import '../../../../helpers/load_app_fonts.dart';
import '../../../../helpers/pump_screen.dart';

const List<PaywallPlanOption> _plans = [
  PaywallPlanOption(
    id: 'annual',
    title: 'Annual',
    subtitle: r'7-day free trial · $3.33 / month',
    price: r'$39.99',
    anchorPrice: r'$59.88',
    badge: 'BEST VALUE · SAVE 33%',
    semanticLabel: 'Annual plan',
  ),
  PaywallPlanOption(
    id: 'monthly',
    title: 'Monthly',
    subtitle: 'Billed monthly · Cancel anytime',
    price: r'$4.99',
    semanticLabel: 'Monthly plan',
  ),
  PaywallPlanOption(
    id: 'enterprise',
    title: 'Enterprise',
    subtitle: 'Slightly less wrong results',
    price: r'$149.99',
    semanticLabel: 'Enterprise plan',
    dense: true,
  ),
];

typedef _Selection = ({String id, String cta, String finePrint});

const _Selection _annual = (
  id: 'annual',
  cta: 'Start 7-day free trial',
  finePrint: r'Then $39.99 / year',
);
const _Selection _monthly = (
  id: 'monthly',
  cta: r'Subscribe for $4.99 / month',
  finePrint: r'Billed $4.99 / month',
);
const _Selection _enterprise = (
  id: 'enterprise',
  cta: r'Subscribe for $149.99 / month',
  finePrint: r'Billed $149.99 / month',
);

PaywallView _view(_Selection selection) => PaywallView(
  plans: _plans,
  selectedPlanId: selection.id,
  ctaLabel: selection.cta,
  finePrint: selection.finePrint,
  socialProofCount: 12482,
  onPlanSelected: (_) {},
  onPurchasePressed: () {},
  onClosePressed: () {},
  onDeclinePressed: () {},
  onRestorePressed: () {},
  onTermsPressed: () {},
  onPrivacyPressed: () {},
  onSystemBackPressed: () {},
);

Future<void> _capture(
  WidgetTester tester, {
  required _Selection selection,
  required double width,
  required String name,
}) async {
  await pumpScreen(tester, _view(selection), size: Size(width, 1000));

  await expectScreenGolden(goldenName(name, width));
}

void main() {
  setUpAll(loadAppFonts);

  for (final width in goldenWidths) {
    testWidgets('should match the golden of the annual plan at $width', (
      tester,
    ) async {
      await _capture(
        tester,
        selection: _annual,
        width: width,
        name: 'paywall-annual',
      );
    });
  }

  testWidgets('should match the golden of the monthly plan', (tester) async {
    await _capture(
      tester,
      selection: _monthly,
      width: 390,
      name: 'paywall-monthly',
    );
  });

  testWidgets('should match the golden of the enterprise plan', (tester) async {
    await _capture(
      tester,
      selection: _enterprise,
      width: 390,
      name: 'paywall-enterprise',
    );
  });
}
