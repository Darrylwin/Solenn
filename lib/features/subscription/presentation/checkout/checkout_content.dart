import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/money_formatter.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_row.dart';
import 'package:solenn/l10n/l10n.dart';

/// Second line of the confirmation header: the chosen plan.
String checkoutPlanName(SubscriptionPlan plan, AppLocalizations l10n) =>
    l10n.checkoutPlanName(plan.name);

/// The summary lines above the amount due.
///
/// A plan with a trial lists the trial, then the price charged after it.
List<CheckoutRow> checkoutRows(PlanOffer offer, AppLocalizations l10n) {
  final price = l10n.pricePerPeriod(
    formatMoney(offer.price),
    offer.billingPeriod.name,
  );

  if (!offer.hasTrial) {
    return [CheckoutRow(label: l10n.checkoutRowPrice, value: price)];
  }
  return [
    CheckoutRow(
      label: l10n.checkoutRowTrial,
      value: l10n.checkoutTrialLength(offer.trialDays),
    ),
    CheckoutRow(label: l10n.checkoutRowThen, value: price),
  ];
}

/// What is charged now: nothing during a trial, the price otherwise.
String checkoutDueToday(PlanOffer offer) {
  if (!offer.hasTrial) return formatMoney(offer.price);
  return formatMoney(
    Money(amountMinor: 0, currencyCode: offer.price.currencyCode),
  );
}
