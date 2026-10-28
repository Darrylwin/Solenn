import 'package:equatable/equatable.dart';
import 'package:solenn/features/subscription/domain/pricing/billing_period.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';

/// The commercial terms of one plan.
///
/// Wording (names, taglines, badges) belongs to the presentation layer.
class PlanOffer extends Equatable {
  /// Creates the terms of [plan].
  const PlanOffer({
    required this.plan,
    required this.billingPeriod,
    required this.price,
    this.trialDays = 0,
  }) : assert(trialDays >= 0, 'A trial cannot be negative.');

  /// The plan these terms apply to.
  final SubscriptionPlan plan;

  /// How often [price] is charged.
  final BillingPeriod billingPeriod;

  /// What each period costs.
  final Money price;

  /// Length of the free trial in days. Zero means there is none.
  final int trialDays;

  /// Whether the plan starts with a free trial.
  bool get hasTrial => trialDays > 0;

  @override
  List<Object> get props => [plan, billingPeriod, price, trialDays];
}
