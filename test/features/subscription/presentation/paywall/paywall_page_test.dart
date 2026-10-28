import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_page.dart';

import '../../../../helpers/pump_screen.dart';

const Size _tall = Size(390, 1600);
const Duration _paywallDelay = Duration(milliseconds: 2500);

class _Harness {
  _Harness() : cubit = SubscriptionCubit(catalog: PricingCatalog.standard);

  final SubscriptionCubit cubit;
  final List<String> links = [];

  Future<void> pump(WidgetTester tester, {bool paywallVisible = true}) async {
    addTearDown(cubit.close);
    await pumpScreen(
      tester,
      RepositoryProvider<PricingCatalog>.value(
        value: PricingCatalog.standard,
        child: BlocProvider<SubscriptionCubit>.value(
          value: cubit,
          child: PaywallPage(
            onTermsPressed: () => links.add('terms'),
            onPrivacyPressed: () => links.add('privacy'),
          ),
        ),
      ),
      size: _tall,
    );
    if (paywallVisible) {
      cubit.calculationCommitted();
      await tester.pump(_paywallDelay);
    }
  }
}

void main() {
  testWidgets('should preselect the annual plan', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);

    expect(find.text('Start 7-day free trial'), findsOneWidget);
    expect(
      find.textContaining(
        r'Then $39.99 / year · Offer ends in',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('should follow the selection of the flow', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);

    await tester.tap(find.text('Monthly'));
    await tester.pump();

    expect(
      harness.cubit.state,
      const PaywallVisible(selectedPlan: SubscriptionPlan.monthly),
    );
    expect(find.text(r'Subscribe for $4.99 / month'), findsOneWidget);
    expect(find.text('Start 7-day free trial'), findsNothing);
    expect(
      find.textContaining(
        r'Billed $4.99 / month · Offer ends in',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('should open the checkout for the selected plan', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);

    await tester.tap(find.text('Enterprise'));
    await tester.pump();
    await tester.tap(find.text(r'Subscribe for $149.99 / month'));
    await tester.pump();

    expect(
      harness.cubit.state,
      const CheckoutVisible(plan: SubscriptionPlan.enterprise),
    );
  });

  group('leaving the paywall', () {
    testWidgets('should unlock with the close button', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(
        harness.cubit.state,
        const Active(Dismissed(DismissReason.closeButton)),
      );
    });

    testWidgets('should unlock with the decline link', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      await tester.tap(find.text('I prefer inaccurate results'));
      await tester.pump();

      expect(
        harness.cubit.state,
        const Active(Dismissed(DismissReason.declined)),
      );
    });

    testWidgets('should unlock with the system back', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(
        harness.cubit.state,
        const Active(Dismissed(DismissReason.systemBack)),
      );
    });

    testWidgets('should unlock by restoring purchases', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      await tester.tap(find.text('Restore'));
      await tester.pump();

      expect(harness.cubit.state, const Active(Restored()));
    });
  });

  testWidgets('should pass the legal links to its caller', (tester) async {
    final harness = _Harness();
    await harness.pump(tester);

    await tester.tap(find.text('Terms'));
    await tester.tap(find.text('Privacy'));

    expect(harness.links, ['terms', 'privacy']);
  });

  testWidgets('should keep the purchased plan selected while it closes', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester);
    await tester.tap(find.text('Monthly'));
    await tester.pump();
    harness.cubit
      ..purchase()
      ..confirmPurchase();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(
      harness.cubit.state,
      const Active(Purchased(SubscriptionPlan.monthly)),
    );
    expect(find.text(r'Subscribe for $4.99 / month'), findsOneWidget);
  });
}
