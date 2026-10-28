import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/pricing/billing_period.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/money_formatter.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';

PlanOffer _annual(int cents, {String currency = 'USD', int trialDays = 0}) =>
    PlanOffer(
      plan: SubscriptionPlan.annual,
      billingPeriod: BillingPeriod.yearly,
      price: Money(amountMinor: cents, currencyCode: currency),
      trialDays: trialDays,
    );

PlanOffer _monthly(int cents, {String currency = 'USD'}) => PlanOffer(
  plan: SubscriptionPlan.monthly,
  billingPeriod: BillingPeriod.monthly,
  price: Money(amountMinor: cents, currencyCode: currency),
);

PlanOffer _enterprise(int cents, {String currency = 'USD'}) => PlanOffer(
  plan: SubscriptionPlan.enterprise,
  billingPeriod: BillingPeriod.monthly,
  price: Money(amountMinor: cents, currencyCode: currency),
);

PricingCatalog _catalog({required int annual, required int monthly}) =>
    PricingCatalog(
      annual: _annual(annual),
      monthly: _monthly(monthly),
      enterprise: _enterprise(monthly * 30),
    );

void main() {
  final standard = PricingCatalog.standard;

  group('the standard catalog', () {
    test('should sell the three plans at the specified prices', () {
      expect(standard.annual.price, const Money.usd(3999));
      expect(standard.monthly.price, const Money.usd(499));
      expect(standard.enterprise.price, const Money.usd(14999));
    });

    test('should give the annual plan a seven-day trial only', () {
      expect(standard.annual.trialDays, 7);
      expect(standard.monthly.hasTrial, isFalse);
      expect(standard.enterprise.hasTrial, isFalse);
    });

    test('should bill the annual plan yearly and the others monthly', () {
      expect(standard.annual.billingPeriod, BillingPeriod.yearly);
      expect(standard.monthly.billingPeriod, BillingPeriod.monthly);
      expect(standard.enterprise.billingPeriod, BillingPeriod.monthly);
    });

    test('should list the offers in display order', () {
      expect(
        standard.offers.map((offer) => offer.plan),
        [
          SubscriptionPlan.annual,
          SubscriptionPlan.monthly,
          SubscriptionPlan.enterprise,
        ],
      );
    });

    test('should preselect the annual plan', () {
      expect(standard.defaultPlan, SubscriptionPlan.annual);
    });

    test('should derive the figures of the paywall', () {
      expect(formatMoney(standard.annualAnchorPrice), r'$59.88');
      expect(formatMoney(standard.annualMonthlyEquivalent), r'$3.33');
      expect(standard.annualSavingsPercent, 33);
    });
  });

  group('offerOf', () {
    test('should return the terms of each plan', () {
      for (final plan in SubscriptionPlan.values) {
        expect(standard.offerOf(plan).plan, plan);
      }
    });
  });

  group('derived figures', () {
    test('should follow the prices', () {
      final catalog = _catalog(annual: 6000, monthly: 1000);

      expect(catalog.annualAnchorPrice, const Money.usd(12000));
      expect(catalog.annualMonthlyEquivalent, const Money.usd(500));
      expect(catalog.annualSavingsPercent, 50);
    });

    test('should round the monthly equivalent half up', () {
      final catalog = _catalog(annual: 1000, monthly: 100);

      expect(catalog.annualMonthlyEquivalent, const Money.usd(83));
      expect(catalog.annualSavingsPercent, 17);
    });

    test('should show no saving when both ways cost the same', () {
      final catalog = _catalog(annual: 1200, monthly: 100);

      expect(catalog.annualSavingsPercent, 0);
      expect(catalog.annualAnchorPrice, catalog.annual.price);
    });
  });

  group('validation', () {
    test('should refuse an offer that does not match its slot', () {
      expect(
        () => PricingCatalog(
          annual: _monthly(100),
          monthly: _monthly(100),
          enterprise: _enterprise(100),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should refuse mismatched billing periods', () {
      expect(
        () => PricingCatalog(
          annual: const PlanOffer(
            plan: SubscriptionPlan.annual,
            billingPeriod: BillingPeriod.monthly,
            price: Money.usd(100),
          ),
          monthly: _monthly(100),
          enterprise: _enterprise(100),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should refuse prices in several currencies', () {
      expect(
        () => PricingCatalog(
          annual: _annual(1000),
          monthly: _monthly(100, currency: 'EUR'),
          enterprise: _enterprise(100),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should refuse an annual plan dearer than twelve months', () {
      expect(
        () => _catalog(annual: 1201, monthly: 100),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('should compare catalogs by value', () {
    expect(
      _catalog(annual: 6000, monthly: 1000),
      _catalog(annual: 6000, monthly: 1000),
    );
    expect(
      _catalog(annual: 6000, monthly: 1000),
      isNot(_catalog(annual: 5000, monthly: 1000)),
    );
  });
}
