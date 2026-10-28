import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_page.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';

import '../../../../helpers/pump_screen.dart';

const Duration _paywallDelay = Duration(milliseconds: 2500);
const Duration _processingDelay = Duration(milliseconds: 1200);

/// Pumps the confirmation of [plan], with the flow already at its checkout.
Future<SubscriptionCubit> _pumpCheckout(
  WidgetTester tester,
  SubscriptionPlan plan,
) async {
  final cubit = SubscriptionCubit(catalog: PricingCatalog.standard);
  addTearDown(cubit.close);

  await pumpScreen(
    tester,
    RepositoryProvider<PricingCatalog>.value(
      value: PricingCatalog.standard,
      child: BlocProvider<SubscriptionCubit>.value(
        value: cubit,
        child: Scaffold(body: CheckoutPage(plan: plan)),
      ),
    ),
  );

  cubit.calculationCommitted();
  await tester.pump(_paywallDelay);
  cubit
    ..selectPlan(plan)
    ..purchase();
  await tester.pump();
  return cubit;
}

void main() {
  testWidgets('should summarize an annual purchase', (tester) async {
    await _pumpCheckout(tester, SubscriptionPlan.annual);

    expect(find.text('Solenn Plus'), findsOneWidget);
    expect(find.text('Annual subscription'), findsOneWidget);
    expect(find.text('Free trial'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text(r'$39.99 / year'), findsOneWidget);
    expect(find.text(r'$0.00'), findsOneWidget);
  });

  testWidgets('should summarize a monthly purchase', (tester) async {
    await _pumpCheckout(tester, SubscriptionPlan.monthly);

    expect(find.text('Monthly subscription'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text(r'$4.99 / month'), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text(r'$4.99'), findsOneWidget);
    expect(find.text('Free trial'), findsNothing);
  });

  testWidgets('should start processing when confirmed', (tester) async {
    final cubit = await _pumpCheckout(tester, SubscriptionPlan.annual);

    await tester.tap(find.text('Confirm subscription'));
    await tester.pump();

    expect(cubit.state, const Processing(plan: SubscriptionPlan.annual));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(_processingDelay);
    expect(cubit.state, const Active(Purchased(SubscriptionPlan.annual)));
  });

  testWidgets('should go back to the paywall when cancelled', (tester) async {
    final cubit = await _pumpCheckout(tester, SubscriptionPlan.enterprise);

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(
      cubit.state,
      const PaywallVisible(selectedPlan: SubscriptionPlan.enterprise),
    );
  });

  testWidgets('should ignore Cancel while processing', (tester) async {
    final cubit = await _pumpCheckout(tester, SubscriptionPlan.annual);
    await tester.tap(find.text('Confirm subscription'));
    await tester.pump();

    await tester.tap(find.text('Cancel'), warnIfMissed: false);
    await tester.pump();

    expect(cubit.state, const Processing(plan: SubscriptionPlan.annual));

    await tester.pump(_processingDelay);
    expect(cubit.state, const Active(Purchased(SubscriptionPlan.annual)));
  });
}
