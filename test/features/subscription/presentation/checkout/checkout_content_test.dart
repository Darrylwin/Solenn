import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_content.dart';
import 'package:solenn/l10n/app_localizations_en.dart';

final AppLocalizationsEn _l10n = AppLocalizationsEn();
final PricingCatalog _catalog = PricingCatalog.standard;

List<(String, String)> _rows(SubscriptionPlan plan) => [
  for (final row in checkoutRows(_catalog.offerOf(plan), _l10n))
    (row.label, row.value),
];

void main() {
  group('checkoutPlanName', () {
    test('should name each plan', () {
      expect(
        checkoutPlanName(SubscriptionPlan.annual, _l10n),
        'Annual subscription',
      );
      expect(
        checkoutPlanName(SubscriptionPlan.monthly, _l10n),
        'Monthly subscription',
      );
      expect(
        checkoutPlanName(SubscriptionPlan.enterprise, _l10n),
        'Enterprise subscription',
      );
    });
  });

  group('checkoutRows', () {
    test('should list the trial, then the price, for a plan with a trial', () {
      expect(_rows(SubscriptionPlan.annual), [
        ('Free trial', '7 days'),
        ('Then', r'$39.99 / year'),
      ]);
    });

    test('should list only the price for a plan without trial', () {
      expect(_rows(SubscriptionPlan.monthly), [('Price', r'$4.99 / month')]);
      expect(_rows(SubscriptionPlan.enterprise), [
        ('Price', r'$149.99 / month'),
      ]);
    });
  });

  group('checkoutDueToday', () {
    test('should charge nothing during a trial', () {
      expect(checkoutDueToday(_catalog.annual), r'$0.00');
    });

    test('should charge the price otherwise', () {
      expect(checkoutDueToday(_catalog.monthly), r'$4.99');
      expect(checkoutDueToday(_catalog.enterprise), r'$149.99');
    });
  });
}
