import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/subscription_timings.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';

/// Runs the subscription flow (specification section 9.1).
///
/// ```text
/// Locked -> PaywallPending -> PaywallVisible <-> CheckoutVisible
///                                  |                  |
///                                  |             Processing
///                                  v                  v
///                                 Active  <-----------+
/// ```
///
/// Every method is a request: one made in a state that cannot honor it is
/// ignored, never an error. The UI cannot always know the state it is acting
/// on (a late tap, a system back during processing), and the flow must stay
/// consistent whatever it sends.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  /// Creates the flow for [catalog], with the delays of [timings].
  SubscriptionCubit({
    required PricingCatalog catalog,
    SubscriptionTimings timings = SubscriptionTimings.standard,
  }) : _catalog = catalog,
       _timings = timings,
       super(const Locked());

  final PricingCatalog _catalog;
  final SubscriptionTimings _timings;
  Timer? _timer;

  /// A calculation was committed.
  ///
  /// Only the first one of the launch matters (rule F1): it starts the wait
  /// that ends with the paywall. Later ones are ignored in every state.
  void calculationCommitted() {
    if (state is! Locked) return;

    emit(const PaywallPending());
    _startTimer(_timings.paywallDelay, _showPaywall);
  }

  /// Selects [plan] on the paywall.
  void selectPlan(SubscriptionPlan plan) {
    final current = state;
    if (current is! PaywallVisible || current.selectedPlan == plan) return;

    emit(PaywallVisible(selectedPlan: plan));
  }

  /// The call to action was pressed: asks to confirm the selected plan.
  void purchase() {
    final current = state;
    if (current is! PaywallVisible) return;

    emit(CheckoutVisible(plan: current.selectedPlan));
  }

  /// The confirmation was cancelled: back to the paywall, same selection.
  void cancelCheckout() {
    final current = state;
    if (current is! CheckoutVisible) return;

    emit(PaywallVisible(selectedPlan: current.plan));
  }

  /// The purchase was confirmed. After the processing delay, the app unlocks.
  void confirmPurchase() {
    final current = state;
    if (current is! CheckoutVisible) return;

    emit(Processing(plan: current.plan));
    _startTimer(_timings.processingDelay, _completePurchase);
  }

  /// The user left the paywall without choosing a plan.
  ///
  /// Every exit unlocks the app (rule F3). It is only honored while the
  /// paywall itself is on screen: closing the checkout sheet is
  /// [cancelCheckout].
  void dismissPaywall(DismissReason reason) {
    if (state is! PaywallVisible) return;

    _unlock(Dismissed(reason));
  }

  /// The user asked to restore purchases.
  ///
  /// It works from the start of the launch to the paywall, from the account
  /// screen or the paywall footer. During the checkout, or once unlocked, it
  /// is ignored.
  void restore() {
    switch (state) {
      case Locked() || PaywallPending() || PaywallVisible():
        _unlock(const Restored());
      case CheckoutVisible() || Processing() || Active():
        return;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _showPaywall() {
    if (state is! PaywallPending) return;

    emit(PaywallVisible(selectedPlan: _catalog.defaultPlan));
  }

  void _completePurchase() {
    final current = state;
    if (current is! Processing) return;

    _unlock(Purchased(current.plan));
  }

  void _unlock(UnlockSource source) {
    _timer?.cancel();
    emit(Active(source));
  }

  void _startTimer(Duration delay, void Function() onElapsed) {
    _timer?.cancel();
    _timer = Timer(delay, onElapsed);
  }
}
