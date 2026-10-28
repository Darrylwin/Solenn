import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/subscription_timings.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';

const Duration _paywallDelay = Duration(milliseconds: 2500);
const Duration _processingDelay = Duration(milliseconds: 1200);
const Duration _longWait = Duration(minutes: 10);

const PaywallVisible _annualPaywall = PaywallVisible(
  selectedPlan: SubscriptionPlan.annual,
);
const PaywallVisible _monthlyPaywall = PaywallVisible(
  selectedPlan: SubscriptionPlan.monthly,
);

SubscriptionCubit _newCubit({
  SubscriptionTimings timings = SubscriptionTimings.standard,
}) => SubscriptionCubit(catalog: PricingCatalog.standard, timings: timings);

/// Runs [body] against a fresh cubit, in a world where time is simulated.
void _scenario(
  String description,
  void Function(SubscriptionCubit, FakeAsync) body, {
  SubscriptionTimings timings = SubscriptionTimings.standard,
}) {
  test(description, () {
    fakeAsync((async) {
      final cubit = _newCubit(timings: timings);
      body(cubit, async);
      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });
}

void _showPaywall(SubscriptionCubit cubit, FakeAsync async) {
  cubit.calculationCommitted();
  async.elapse(_paywallDelay);
}

void _openCheckout(
  SubscriptionCubit cubit,
  FakeAsync async, {
  SubscriptionPlan? plan,
}) {
  _showPaywall(cubit, async);
  if (plan != null) cubit.selectPlan(plan);
  cubit.purchase();
}

void _process(SubscriptionCubit cubit, FakeAsync async) {
  _openCheckout(cubit, async, plan: SubscriptionPlan.monthly);
  cubit.confirmPurchase();
}

void _unlockByDismissal(SubscriptionCubit cubit, FakeAsync async) {
  _showPaywall(cubit, async);
  cubit.dismissPaywall(DismissReason.closeButton);
}

void main() {
  group('the paywall delay', () {
    _scenario('should start locked', (cubit, async) {
      expect(cubit.state, const Locked());
    });

    _scenario('should wait for the first calculation', (cubit, async) {
      async.elapse(_longWait);

      expect(cubit.state, const Locked());
    });

    _scenario('should announce the paywall at the first calculation', (
      cubit,
      async,
    ) {
      cubit.calculationCommitted();

      expect(cubit.state, const PaywallPending());
    });

    _scenario('should show the paywall after two and a half seconds', (
      cubit,
      async,
    ) {
      cubit.calculationCommitted();

      async.elapse(_paywallDelay - const Duration(milliseconds: 1));
      expect(cubit.state, const PaywallPending());

      async.elapse(const Duration(milliseconds: 1));
      expect(cubit.state, _annualPaywall);
    });

    _scenario('should preselect the plan the catalog recommends', (
      cubit,
      async,
    ) {
      _showPaywall(cubit, async);

      expect(
        (cubit.state as PaywallVisible).selectedPlan,
        PricingCatalog.standard.defaultPlan,
      );
    });

    _scenario('should not restart the wait at a second calculation', (
      cubit,
      async,
    ) {
      cubit.calculationCommitted();
      async.elapse(const Duration(milliseconds: 2000));

      cubit.calculationCommitted();
      async.elapse(const Duration(milliseconds: 500));

      expect(cubit.state, _annualPaywall);
    });

    _scenario('should ignore further calculations once the paywall shows', (
      cubit,
      async,
    ) {
      _showPaywall(cubit, async);

      cubit.calculationCommitted();
      async.elapse(_longWait);

      expect(cubit.state, _annualPaywall);
    });

    _scenario(
      'should follow the delay it is given',
      (cubit, async) {
        cubit.calculationCommitted();

        async.elapse(const Duration(milliseconds: 9));
        expect(cubit.state, const PaywallPending());

        async.elapse(const Duration(milliseconds: 1));
        expect(cubit.state, _annualPaywall);
      },
      timings: const SubscriptionTimings(
        paywallDelay: Duration(milliseconds: 10),
      ),
    );
  });

  group('choosing a plan', () {
    _scenario('should select another plan', (cubit, async) {
      _showPaywall(cubit, async);

      cubit.selectPlan(SubscriptionPlan.enterprise);

      expect(
        cubit.state,
        const PaywallVisible(selectedPlan: SubscriptionPlan.enterprise),
      );
    });

    _scenario('should emit nothing when the plan is already selected', (
      cubit,
      async,
    ) {
      final states = <SubscriptionState>[];
      cubit.stream.listen(states.add);
      _showPaywall(cubit, async);
      async.flushMicrotasks();
      states.clear();

      cubit.selectPlan(SubscriptionPlan.annual);
      async.flushMicrotasks();

      expect(states, isEmpty);
    });

    _scenario('should ignore a selection before the paywall', (cubit, async) {
      cubit.selectPlan(SubscriptionPlan.monthly);
      expect(cubit.state, const Locked());

      cubit
        ..calculationCommitted()
        ..selectPlan(SubscriptionPlan.monthly);
      expect(cubit.state, const PaywallPending());
    });

    _scenario('should ignore a selection during the checkout', (cubit, async) {
      _openCheckout(cubit, async);

      cubit.selectPlan(SubscriptionPlan.monthly);

      expect(
        cubit.state,
        const CheckoutVisible(plan: SubscriptionPlan.annual),
      );
    });
  });

  group('the checkout', () {
    _scenario('should open for the selected plan', (cubit, async) {
      _openCheckout(cubit, async, plan: SubscriptionPlan.monthly);

      expect(
        cubit.state,
        const CheckoutVisible(plan: SubscriptionPlan.monthly),
      );
    });

    _scenario('should not open before the paywall', (cubit, async) {
      cubit.purchase();
      expect(cubit.state, const Locked());

      cubit
        ..calculationCommitted()
        ..purchase();
      expect(cubit.state, const PaywallPending());
    });

    _scenario('should go back to the paywall, keeping the selection', (
      cubit,
      async,
    ) {
      _openCheckout(cubit, async, plan: SubscriptionPlan.enterprise);

      cubit.cancelCheckout();

      expect(
        cubit.state,
        const PaywallVisible(selectedPlan: SubscriptionPlan.enterprise),
      );
    });

    _scenario('should be able to open again after a cancellation', (
      cubit,
      async,
    ) {
      _openCheckout(cubit, async);
      cubit
        ..cancelCheckout()
        ..purchase();

      expect(
        cubit.state,
        const CheckoutVisible(plan: SubscriptionPlan.annual),
      );
    });

    _scenario('should ignore a cancellation outside the checkout', (
      cubit,
      async,
    ) {
      cubit.cancelCheckout();
      expect(cubit.state, const Locked());

      _showPaywall(cubit, async);
      cubit.cancelCheckout();
      expect(cubit.state, _annualPaywall);
    });
  });

  group('a purchase', () {
    _scenario('should be processing once confirmed', (cubit, async) {
      _openCheckout(cubit, async, plan: SubscriptionPlan.monthly);

      cubit.confirmPurchase();

      expect(
        cubit.state,
        const Processing(plan: SubscriptionPlan.monthly),
      );
    });

    _scenario('should unlock after the processing delay', (cubit, async) {
      _process(cubit, async);

      async.elapse(_processingDelay - const Duration(milliseconds: 1));
      expect(cubit.state, const Processing(plan: SubscriptionPlan.monthly));

      async.elapse(const Duration(milliseconds: 1));
      expect(
        cubit.state,
        const Active(Purchased(SubscriptionPlan.monthly)),
      );
    });

    _scenario('should not be confirmed outside the checkout', (cubit, async) {
      cubit.confirmPurchase();
      expect(cubit.state, const Locked());

      _showPaywall(cubit, async);
      cubit.confirmPurchase();
      expect(cubit.state, _annualPaywall);
    });

    _scenario(
      'should follow the processing delay it is given',
      (cubit, async) {
        _process(cubit, async);

        async.elapse(const Duration(milliseconds: 4));
        expect(cubit.state, isA<Processing>());

        async.elapse(const Duration(milliseconds: 1));
        expect(cubit.state, isA<Active>());
      },
      timings: const SubscriptionTimings(
        paywallDelay: Duration(milliseconds: 1),
        processingDelay: Duration(milliseconds: 5),
      ),
    );

    _scenario('should ignore every request while processing', (cubit, async) {
      _process(cubit, async);
      const processing = Processing(plan: SubscriptionPlan.monthly);

      cubit
        ..selectPlan(SubscriptionPlan.annual)
        ..purchase()
        ..cancelCheckout()
        ..confirmPurchase()
        ..dismissPaywall(DismissReason.closeButton)
        ..restore()
        ..calculationCommitted();

      expect(cubit.state, processing);

      async.elapse(_processingDelay);
      expect(
        cubit.state,
        const Active(Purchased(SubscriptionPlan.monthly)),
      );
    });
  });

  group('leaving the paywall', () {
    for (final reason in DismissReason.values) {
      _scenario('should unlock after $reason', (cubit, async) {
        _showPaywall(cubit, async);

        cubit.dismissPaywall(reason);

        expect(cubit.state, Active(Dismissed(reason)));
      });
    }

    _scenario('should not dismiss a paywall that is not on screen', (
      cubit,
      async,
    ) {
      cubit.dismissPaywall(DismissReason.closeButton);
      expect(cubit.state, const Locked());

      cubit
        ..calculationCommitted()
        ..dismissPaywall(DismissReason.closeButton);
      expect(cubit.state, const PaywallPending());
    });

    _scenario('should not dismiss the checkout as a paywall', (cubit, async) {
      _openCheckout(cubit, async);

      cubit.dismissPaywall(DismissReason.systemBack);

      expect(
        cubit.state,
        const CheckoutVisible(plan: SubscriptionPlan.annual),
      );
    });
  });

  group('restoring purchases', () {
    _scenario('should unlock before any calculation', (cubit, async) {
      cubit.restore();

      expect(cubit.state, const Active(Restored()));
    });

    _scenario('should unlock while the paywall is pending, for good', (
      cubit,
      async,
    ) {
      final states = <SubscriptionState>[];
      cubit.stream.listen(states.add);
      cubit
        ..calculationCommitted()
        ..restore();
      async
        ..elapse(_longWait)
        ..flushMicrotasks();

      expect(cubit.state, const Active(Restored()));
      expect(states, [const PaywallPending(), const Active(Restored())]);
    });

    _scenario('should unlock from the paywall', (cubit, async) {
      _showPaywall(cubit, async);

      cubit.restore();

      expect(cubit.state, const Active(Restored()));
    });

    _scenario('should be ignored during the checkout', (cubit, async) {
      _openCheckout(cubit, async);

      cubit.restore();

      expect(
        cubit.state,
        const CheckoutVisible(plan: SubscriptionPlan.annual),
      );
    });

    _scenario('should not change why the app is unlocked', (cubit, async) {
      _process(cubit, async);
      async.elapse(_processingDelay);

      cubit.restore();

      expect(
        cubit.state,
        const Active(Purchased(SubscriptionPlan.monthly)),
      );
    });
  });

  group('once unlocked', () {
    _scenario('should ignore every request, for good', (cubit, async) {
      _unlockByDismissal(cubit, async);
      const unlocked = Active(Dismissed(DismissReason.closeButton));

      cubit
        ..calculationCommitted()
        ..selectPlan(SubscriptionPlan.monthly)
        ..purchase()
        ..cancelCheckout()
        ..confirmPurchase()
        ..dismissPaywall(DismissReason.systemBack)
        ..restore();
      async.elapse(_longWait);

      expect(cubit.state, unlocked);
    });
  });

  group('the states it goes through', () {
    _scenario('should emit each step of a purchase, once', (cubit, async) {
      final states = <SubscriptionState>[];
      cubit.stream.listen(states.add);

      cubit.calculationCommitted();
      async.elapse(_paywallDelay);
      cubit
        ..selectPlan(SubscriptionPlan.monthly)
        ..purchase()
        ..confirmPurchase();
      async
        ..elapse(_processingDelay)
        ..flushMicrotasks();

      expect(states, [
        const PaywallPending(),
        _annualPaywall,
        _monthlyPaywall,
        const CheckoutVisible(plan: SubscriptionPlan.monthly),
        const Processing(plan: SubscriptionPlan.monthly),
        const Active(Purchased(SubscriptionPlan.monthly)),
      ]);
    });

    _scenario('should emit each step of a dismissal, once', (cubit, async) {
      final states = <SubscriptionState>[];
      cubit.stream.listen(states.add);

      _showPaywall(cubit, async);
      cubit.dismissPaywall(DismissReason.declined);
      async.flushMicrotasks();

      expect(states, [
        const PaywallPending(),
        _annualPaywall,
        const Active(Dismissed(DismissReason.declined)),
      ]);
    });

    _scenario('should come back to the paywall after a cancelled checkout', (
      cubit,
      async,
    ) {
      final states = <SubscriptionState>[];
      cubit.stream.listen(states.add);

      _openCheckout(cubit, async);
      cubit.cancelCheckout();
      async.flushMicrotasks();

      expect(states.last, _annualPaywall);
      expect(states, hasLength(4));
    });
  });

  group('closing', () {
    _scenario('should cancel a pending paywall', (cubit, async) {
      cubit.calculationCommitted();

      unawaited(cubit.close());
      async
        ..flushMicrotasks()
        ..elapse(_longWait);

      expect(cubit.state, const PaywallPending());
    });

    _scenario('should cancel a purchase in progress', (cubit, async) {
      _process(cubit, async);

      unawaited(cubit.close());
      async
        ..flushMicrotasks()
        ..elapse(_longWait);

      expect(cubit.state, const Processing(plan: SubscriptionPlan.monthly));
    });
  });
}
