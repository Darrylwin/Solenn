import 'package:solenn/features/subscription/domain/pricing/money_formatter.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_plan_option.dart';
import 'package:solenn/l10n/l10n.dart';

/// Number displayed in the social proof line of the paywall.
const int paywallSocialProofCount = 12482;

const String _spokenSeparator = ', ';

/// The plan cards of the paywall, in display order.
///
/// Every figure comes from [catalog]. The annual plan shows its savings only
/// when there are some.
List<PaywallPlanOption> buildPlanOptions(
  PricingCatalog catalog,
  AppLocalizations l10n,
) {
  return [
    for (final offer in catalog.offers) _optionFor(offer, catalog, l10n),
  ];
}

/// Label of the main button for the plan sold by [offer].
String paywallCtaLabel(PlanOffer offer, AppLocalizations l10n) {
  if (offer.hasTrial) {
    return l10n.ctaStartTrial(l10n.planTrial(offer.trialDays));
  }
  return l10n.ctaSubscribe(_pricePerPeriod(offer, l10n));
}

/// Line under the main button: what will be charged.
String paywallFinePrint(PlanOffer offer, AppLocalizations l10n) {
  final price = _pricePerPeriod(offer, l10n);
  return offer.hasTrial
      ? l10n.finePrintAfterTrial(price)
      : l10n.finePrintBilled(price);
}

String _pricePerPeriod(PlanOffer offer, AppLocalizations l10n) =>
    l10n.pricePerPeriod(formatMoney(offer.price), offer.billingPeriod.name);

PaywallPlanOption _optionFor(
  PlanOffer offer,
  PricingCatalog catalog,
  AppLocalizations l10n,
) {
  final title = l10n.planTitle(offer.plan.name);
  final price = formatMoney(offer.price);
  final head = l10n.planSemanticsHead(
    title,
    l10n.priceSpokenPerPeriod(price, offer.billingPeriod.name),
  );

  return switch (offer.plan) {
    SubscriptionPlan.annual => _annualOption(
      offer: offer,
      catalog: catalog,
      l10n: l10n,
      title: title,
      price: price,
      head: head,
    ),
    SubscriptionPlan.monthly => PaywallPlanOption(
      id: offer.plan.name,
      title: title,
      subtitle: l10n.planSubtitleMonthly,
      price: price,
      semanticLabel: [
        head,
        l10n.planSemanticsBilledMonthly,
      ].join(_spokenSeparator),
    ),
    SubscriptionPlan.enterprise => PaywallPlanOption(
      id: offer.plan.name,
      title: title,
      subtitle: l10n.planSubtitleEnterprise,
      price: price,
      dense: true,
      semanticLabel: [head, l10n.planSubtitleEnterprise].join(_spokenSeparator),
    ),
  };
}

PaywallPlanOption _annualOption({
  required PlanOffer offer,
  required PricingCatalog catalog,
  required AppLocalizations l10n,
  required String title,
  required String price,
  required String head,
}) {
  final savings = catalog.annualSavingsPercent;
  final hasSavings = savings > 0;
  final equivalent = formatMoney(catalog.annualMonthlyEquivalent);
  final trial = offer.hasTrial ? l10n.planTrial(offer.trialDays) : null;

  return PaywallPlanOption(
    id: offer.plan.name,
    title: title,
    subtitle: trial == null
        ? l10n.planMonthlyEquivalent(equivalent)
        : l10n.planTrialThenMonthly(trial, equivalent),
    price: price,
    anchorPrice: hasSavings ? formatMoney(catalog.annualAnchorPrice) : null,
    badge: hasSavings ? l10n.planBestValueBadge(savings) : null,
    semanticLabel: [
      head,
      ?trial,
      if (hasSavings) l10n.planSemanticsSavings(savings),
    ].join(_spokenSeparator),
  );
}
