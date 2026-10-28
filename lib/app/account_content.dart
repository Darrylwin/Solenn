import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/l10n/l10n.dart';

/// What the plan card of the account screen shows.
typedef AccountPlan = ({String name, String detail, String? badge});

/// Describes the plan the user is on, from the state of the flow.
///
/// Before the app is unlocked the user is on the free plan. Every way of
/// unlocking it gives the Plus plan; only a purchase has a real plan to name.
AccountPlan accountPlanFor(
  SubscriptionState state,
  PricingCatalog catalog,
  AppLocalizations l10n,
) {
  return switch (state) {
    Active(:final source) => (
      name: l10n.checkoutProductName,
      detail: _detail(source, catalog, l10n),
      badge: l10n.plusBadge,
    ),
    Locked() ||
    PaywallPending() ||
    PaywallVisible() ||
    CheckoutVisible() ||
    Processing() => (
      name: l10n.accountPlanFree,
      detail: l10n.accountPlanFreeDetail,
      badge: null,
    ),
  };
}

String _detail(
  UnlockSource source,
  PricingCatalog catalog,
  AppLocalizations l10n,
) {
  return switch (source) {
    Purchased(:final plan) => _purchasedDetail(catalog.offerOf(plan), l10n),
    Dismissed() => l10n.accountPlanDismissedDetail,
    Restored() => l10n.accountPlanRestoredDetail,
  };
}

String _purchasedDetail(PlanOffer offer, AppLocalizations l10n) {
  final title = l10n.planTitle(offer.plan.name);
  if (!offer.hasTrial) return title;
  return l10n.accountPlanDetailTrial(title, l10n.planTrial(offer.trialDays));
}
