import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/app/paywall_route.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_page.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_page.dart';

/// Turns the state of the subscription flow into navigation.
///
/// The Cubit never navigates (AR-10): this widget listens to it and opens or
/// closes the paywall and the checkout sheet accordingly. It sits inside the
/// navigator, on the home screen, so the surfaces it opens go on top of
/// whatever is showing.
///
/// Each surface is opened once. If the user closes the checkout sheet
/// themselves (swipe, scrim, back), the flow is told to cancel the checkout.
class PaywallPresenter extends StatefulWidget {
  /// Creates the presenter around [child].
  const PaywallPresenter({
    required this.child,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    super.key,
  });

  /// The screen the surfaces open over.
  final Widget child;

  /// Called when Terms is tapped on the paywall.
  final VoidCallback onTermsPressed;

  /// Called when Privacy is tapped on the paywall.
  final VoidCallback onPrivacyPressed;

  @override
  State<PaywallPresenter> createState() => _PaywallPresenterState();
}

class _PaywallPresenterState extends State<PaywallPresenter> {
  bool _paywallOpen = false;
  bool _checkoutOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionCubit, SubscriptionState>(
      listener: _present,
      child: widget.child,
    );
  }

  void _present(BuildContext context, SubscriptionState state) {
    switch (state) {
      case Locked() || PaywallPending() || Processing():
        // Nothing to show, or the checkout sheet updates itself.
        return;
      case PaywallVisible():
        if (_checkoutOpen) {
          // Back from the checkout: the sheet is the top route.
          Navigator.of(context).pop();
        } else if (!_paywallOpen) {
          _openPaywall(context);
        }
      case CheckoutVisible(:final plan):
        unawaited(_openCheckout(context, plan));
      case Active():
        Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _openPaywall(BuildContext context) {
    _paywallOpen = true;
    final route = buildPaywallRoute(
      context,
      builder: (_) => PaywallPage(
        onTermsPressed: widget.onTermsPressed,
        onPrivacyPressed: widget.onPrivacyPressed,
      ),
    );

    unawaited(
      Navigator.of(
        context,
      ).push(route).whenComplete(() => _paywallOpen = false),
    );
  }

  Future<void> _openCheckout(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    if (_checkoutOpen) return;
    _checkoutOpen = true;
    final cubit = context.read<SubscriptionCubit>();

    await showSolennSheet<void>(
      context: context,
      builder: (_) => CheckoutPage(plan: plan),
    );

    _checkoutOpen = false;
    // The user closed the sheet themselves: that is a cancellation. Once the
    // purchase is processing or done, the flow carries on by itself.
    if (cubit.state is CheckoutVisible) cubit.cancelCheckout();
  }
}
