import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';

void main() {
  test('should only report the unlocked state as unlocked', () {
    const states = <SubscriptionState>[
      Locked(),
      PaywallPending(),
      PaywallVisible(selectedPlan: SubscriptionPlan.annual),
      CheckoutVisible(plan: SubscriptionPlan.annual),
      Processing(plan: SubscriptionPlan.annual),
    ];

    for (final state in states) {
      expect(state.isUnlocked, isFalse, reason: '$state');
    }
    expect(const Active(Restored()).isUnlocked, isTrue);
  });

  test('should compare states by value', () {
    expect(const Locked(), const Locked());
    expect(const PaywallPending(), const PaywallPending());
    expect(
      const PaywallVisible(selectedPlan: SubscriptionPlan.annual),
      const PaywallVisible(selectedPlan: SubscriptionPlan.annual),
    );
    expect(
      const PaywallVisible(selectedPlan: SubscriptionPlan.annual),
      isNot(const PaywallVisible(selectedPlan: SubscriptionPlan.monthly)),
    );
    expect(
      const CheckoutVisible(plan: SubscriptionPlan.annual),
      isNot(const Processing(plan: SubscriptionPlan.annual)),
    );
    expect(
      const Active(Dismissed(DismissReason.closeButton)),
      isNot(const Active(Dismissed(DismissReason.declined))),
    );
  });
}
