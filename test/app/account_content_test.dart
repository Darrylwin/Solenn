import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/account_content.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/billing_period.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/plan_offer.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/l10n/app_localizations_en.dart';

final AppLocalizationsEn _l10n = AppLocalizationsEn();

/// A catalog whose annual plan has no trial.
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

AccountPlan _plan(SubscriptionState state, {PricingCatalog? catalog}) =>
    accountPlanFor(state, catalog ?? PricingCatalog.standard, _l10n);

void main() {
  group('before the app is unlocked', () {
    const states = <SubscriptionState>[
      Locked(),
      PaywallPending(),
      PaywallVisible(selectedPlan: SubscriptionPlan.annual),
      CheckoutVisible(plan: SubscriptionPlan.annual),
      Processing(plan: SubscriptionPlan.annual),
    ];

    for (final state in states) {
      test('should describe the free plan in $state', () {
        expect(_plan(state), (
          name: 'Solenn Free',
          detail: 'Standard accuracy',
          badge: null,
        ));
      });
    }
  });

  group('after a purchase', () {
    test('should name the plan and its trial', () {
      expect(_plan(const Active(Purchased(SubscriptionPlan.annual))), (
        name: 'Solenn Plus',
        detail: 'Annual · 7-day free trial',
        badge: 'PLUS',
      ));
    });

    test('should name a plan without trial alone', () {
      expect(
        _plan(const Active(Purchased(SubscriptionPlan.monthly))).detail,
        'Monthly',
      );
      expect(
        _plan(const Active(Purchased(SubscriptionPlan.enterprise))).detail,
        'Enterprise',
      );
    });

    test('should not mention a trial the catalog does not offer', () {
      final plan = _plan(
        const Active(Purchased(SubscriptionPlan.annual)),
        catalog: _plain,
      );

      expect(plan.detail, 'Annual');
    });
  });

  group('without a purchase', () {
    test('should describe a dismissed paywall', () {
      expect(
        _plan(const Active(Dismissed(DismissReason.closeButton))),
        (
          name: 'Solenn Plus',
          detail: 'Complimentary access',
          badge: 'PLUS',
        ),
      );
    });

    test('should describe restored purchases', () {
      expect(_plan(const Active(Restored())), (
        name: 'Solenn Plus',
        detail: 'Restored purchase',
        badge: 'PLUS',
      ));
    });
  });
}
