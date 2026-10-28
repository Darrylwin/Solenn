import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/pricing/billing_period.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';

PlanOffer _offer({int trialDays = 0}) => PlanOffer(
  plan: SubscriptionPlan.annual,
  billingPeriod: BillingPeriod.yearly,
  price: const Money.usd(3999),
  trialDays: trialDays,
);

void main() {
  test('should have no trial by default', () {
    expect(_offer().trialDays, 0);
    expect(_offer().hasTrial, isFalse);
  });

  test('should report a trial when it has days', () {
    expect(_offer(trialDays: 7).hasTrial, isTrue);
  });

  test('should refuse a negative trial', () {
    expect(() => _offer(trialDays: -1), throwsA(isA<AssertionError>()));
  });

  test('should compare offers by value', () {
    expect(_offer(trialDays: 7), _offer(trialDays: 7));
    expect(_offer(trialDays: 7), isNot(_offer()));
  });
}
