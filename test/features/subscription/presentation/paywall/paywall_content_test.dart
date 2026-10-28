import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/pricing/billing_period.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_content.dart';
import 'package:solenn/l10n/app_localizations_en.dart';

final AppLocalizationsEn _l10n = AppLocalizationsEn();

/// A catalog where the annual plan saves nothing and has no trial.
final PricingCatalog _plain = PricingCatalog(
  annual: const PlanOffer(
    plan: SubscriptionPlan.annual,
    billingPeriod: BillingPeriod.yearly,
    price: Money.usd(1200),
  ),
  monthly: const PlanOffer(
    plan: SubscriptionPlan.monthly,
    billingPeriod: BillingPeriod.monthly,
    price: Money.usd(100),
  ),
  enterprise: const PlanOffer(
    plan: SubscriptionPlan.enterprise,
    billingPeriod: BillingPeriod.monthly,
    price: Money.usd(3000),
  ),
);

PlanOffer _annualWithTrial(int days) => PlanOffer(
  plan: SubscriptionPlan.annual,
  billingPeriod: BillingPeriod.yearly,
  price: const Money.usd(3999),
  trialDays: days,
);

void main() {
  final options = buildPlanOptions(PricingCatalog.standard, _l10n);

  group('buildPlanOptions with the standard catalog', () {
    test('should list the plans in display order', () {
      expect(options.map((option) => option.id), [
        'annual',
        'monthly',
        'enterprise',
      ]);
      expect(options.map((option) => option.title), [
        'Annual',
        'Monthly',
        'Enterprise',
      ]);
    });

    test('should show the prices of the catalog', () {
      expect(options.map((option) => option.price), [
        r'$39.99',
        r'$4.99',
        r'$149.99',
      ]);
    });

    test('should sell the annual plan with its trial, anchor and badge', () {
      final annual = options[0];

      expect(annual.subtitle, r'7-day free trial · $3.33 / month');
      expect(annual.anchorPrice, r'$59.88');
      expect(annual.badge, 'BEST VALUE · SAVE 33%');
      expect(annual.dense, isFalse);
    });

    test('should describe the monthly plan', () {
      final monthly = options[1];

      expect(monthly.subtitle, 'Billed monthly · Cancel anytime');
      expect(monthly.anchorPrice, isNull);
      expect(monthly.badge, isNull);
      expect(monthly.dense, isFalse);
    });

    test('should show the enterprise plan as a compact decoy', () {
      final enterprise = options[2];

      expect(enterprise.subtitle, 'Slightly less wrong results');
      expect(enterprise.dense, isTrue);
      expect(enterprise.badge, isNull);
    });

    test('should read each card as one sentence', () {
      expect(
        options.map((option) => option.semanticLabel),
        [
          r'Annual plan, $39.99 per year, 7-day free trial, save 33 percent',
          r'Monthly plan, $4.99 per month, billed monthly, cancel anytime',
          r'Enterprise plan, $149.99 per month, Slightly less wrong results',
        ],
      );
    });
  });

  group('buildPlanOptions without savings or trial', () {
    final plain = buildPlanOptions(_plain, _l10n)[0];

    test('should drop the anchor price and the badge', () {
      expect(plain.anchorPrice, isNull);
      expect(plain.badge, isNull);
    });

    test('should show the monthly equivalent alone', () {
      expect(plain.subtitle, r'$1.00 / month');
    });

    test('should read the card without trial or savings', () {
      expect(plain.semanticLabel, r'Annual plan, $12.00 per year');
    });
  });

  group('paywallCtaLabel', () {
    final catalog = PricingCatalog.standard;

    test('should offer the trial when there is one', () {
      expect(paywallCtaLabel(catalog.annual, _l10n), 'Start 7-day free trial');
    });

    test('should speak of one day in the singular', () {
      expect(
        paywallCtaLabel(_annualWithTrial(1), _l10n),
        'Start 1-day free trial',
      );
    });

    test('should name the price when there is no trial', () {
      expect(
        paywallCtaLabel(catalog.monthly, _l10n),
        r'Subscribe for $4.99 / month',
      );
      expect(
        paywallCtaLabel(catalog.enterprise, _l10n),
        r'Subscribe for $149.99 / month',
      );
      expect(
        paywallCtaLabel(_plain.annual, _l10n),
        r'Subscribe for $12.00 / year',
      );
    });
  });

  group('paywallFinePrint', () {
    final catalog = PricingCatalog.standard;

    test('should announce what follows the trial', () {
      expect(paywallFinePrint(catalog.annual, _l10n), r'Then $39.99 / year');
    });

    test('should say what is billed when there is no trial', () {
      expect(paywallFinePrint(catalog.monthly, _l10n), r'Billed $4.99 / month');
      expect(paywallFinePrint(_plain.annual, _l10n), r'Billed $12.00 / year');
    });
  });

  test('should show the social proof of the specification', () {
    expect(paywallSocialProofCount, 12482);
  });
}
