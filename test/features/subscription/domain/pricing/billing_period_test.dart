import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/pricing/billing_period.dart';

void main() {
  test('should cover one month or twelve', () {
    expect(BillingPeriod.monthly.months, 1);
    expect(BillingPeriod.yearly.months, 12);
  });
}
