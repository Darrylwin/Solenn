import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_content.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';
import 'package:solenn/l10n/l10n.dart';

/// The paywall, wired to the subscription flow.
///
/// The Cubit and the catalog come from the tree: the flow belongs to the
/// launch, so the `app` layer provides them. Navigating to the legal pages is
/// the caller's business.
class PaywallPage extends StatelessWidget {
  /// Creates the page.
  const PaywallPage({
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    super.key,
  });

  /// Called when Terms is tapped.
  final VoidCallback onTermsPressed;

  /// Called when Privacy is tapped.
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SubscriptionCubit>();
    final catalog = context.read<PricingCatalog>();
    final l10n = context.l10n;
    final options = buildPlanOptions(catalog, l10n);

    return BlocSelector<SubscriptionCubit, SubscriptionState, SubscriptionPlan>(
      selector: (state) => _selectedPlan(state, catalog),
      builder: (context, plan) {
        final offer = catalog.offerOf(plan);

        return PaywallView(
          plans: options,
          selectedPlanId: plan.name,
          ctaLabel: paywallCtaLabel(offer, l10n),
          finePrint: paywallFinePrint(offer, l10n),
          socialProofCount: paywallSocialProofCount,
          onPlanSelected: (id) =>
              cubit.selectPlan(SubscriptionPlan.values.byName(id)),
          onPurchasePressed: cubit.purchase,
          onClosePressed: () => cubit.dismissPaywall(DismissReason.closeButton),
          onDeclinePressed: () => cubit.dismissPaywall(DismissReason.declined),
          onRestorePressed: cubit.restore,
          onTermsPressed: onTermsPressed,
          onPrivacyPressed: onPrivacyPressed,
          onSystemBackPressed: () =>
              cubit.dismissPaywall(DismissReason.systemBack),
        );
      },
    );
  }

  /// The plan the paywall shows as selected.
  ///
  /// It stays on the purchased plan while the paywall slides away, so the card
  /// does not flicker back to the default one.
  SubscriptionPlan _selectedPlan(
    SubscriptionState state,
    PricingCatalog catalog,
  ) {
    return switch (state) {
      PaywallVisible(:final selectedPlan) => selectedPlan,
      CheckoutVisible(:final plan) => plan,
      Processing(:final plan) => plan,
      Active(source: Purchased(:final plan)) => plan,
      Locked() || PaywallPending() || Active() => catalog.defaultPlan,
    };
  }
}
