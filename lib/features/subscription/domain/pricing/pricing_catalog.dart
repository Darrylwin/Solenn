import 'package:equatable/equatable.dart';
import 'package:solenn/features/subscription/domain/pricing/billing_period.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';

/// The plans on sale and the figures derived from their prices.
///
/// Derived figures are computed, never typed in: changing a price updates the
/// struck-through price, the monthly equivalent and the savings together.
class PricingCatalog extends Equatable {
  /// Creates a catalog. The three offers must match their plan, the annual
  /// one must be billed yearly and the others monthly, and every price must
  /// share one currency.
  PricingCatalog({
    required this.annual,
    required this.monthly,
    required this.enterprise,
  }) : assert(annual.plan == SubscriptionPlan.annual, 'Wrong annual offer.'),
       assert(monthly.plan == SubscriptionPlan.monthly, 'Wrong monthly offer.'),
       assert(
         enterprise.plan == SubscriptionPlan.enterprise,
         'Wrong enterprise offer.',
       ),
       assert(
         annual.billingPeriod == BillingPeriod.yearly &&
             monthly.billingPeriod == BillingPeriod.monthly &&
             enterprise.billingPeriod == BillingPeriod.monthly,
         'Billing periods do not match the plans.',
       ),
       assert(
         {
               annual.price.currencyCode,
               monthly.price.currencyCode,
               enterprise.price.currencyCode,
             }.length ==
             1,
         'Every price must use one currency.',
       ),
       assert(
         annual.price.amountMinor <=
             monthly.price.times(annual.billingPeriod.months).amountMinor,
         'The annual plan must not cost more than twelve monthly payments.',
       );

  /// The catalog of the application (specification section 9.2).
  static final PricingCatalog standard = PricingCatalog(
    annual: const PlanOffer(
      plan: SubscriptionPlan.annual,
      billingPeriod: BillingPeriod.yearly,
      price: Money.usd(3999),
      trialDays: 7,
    ),
    monthly: const PlanOffer(
      plan: SubscriptionPlan.monthly,
      billingPeriod: BillingPeriod.monthly,
      price: Money.usd(499),
    ),
    enterprise: const PlanOffer(
      plan: SubscriptionPlan.enterprise,
      billingPeriod: BillingPeriod.monthly,
      price: Money.usd(14999),
    ),
  );

  /// The yearly plan.
  final PlanOffer annual;

  /// The monthly plan.
  final PlanOffer monthly;

  /// The decoy plan.
  final PlanOffer enterprise;

  /// Every offer, in display order.
  List<PlanOffer> get offers => [annual, monthly, enterprise];

  /// The plan selected when the paywall opens.
  SubscriptionPlan get defaultPlan => annual.plan;

  /// The terms of [plan].
  PlanOffer offerOf(SubscriptionPlan plan) => switch (plan) {
    SubscriptionPlan.annual => annual,
    SubscriptionPlan.monthly => monthly,
    SubscriptionPlan.enterprise => enterprise,
  };

  /// What the annual plan would cost paid month by month: the reference price
  /// shown struck through.
  Money get annualAnchorPrice =>
      monthly.price.times(annual.billingPeriod.months);

  /// What one month of the annual plan costs, rounded half up.
  Money get annualMonthlyEquivalent =>
      annual.price.dividedBy(annual.billingPeriod.months);

  /// The whole percentage saved by choosing the annual plan, rounded half up.
  int get annualSavingsPercent => annual.price.percentBelow(annualAnchorPrice);

  @override
  List<Object> get props => [annual, monthly, enterprise];
}
