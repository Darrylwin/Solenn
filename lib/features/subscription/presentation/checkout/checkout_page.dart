import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_content.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_view.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/l10n/l10n.dart';

/// The purchase confirmation of one plan, wired to the subscription flow.
///
/// The plan is fixed for the life of the sheet: it is the one the flow was
/// confirming when the sheet opened. While the purchase is processing, the
/// back button and the scrim are ignored.
class CheckoutPage extends StatelessWidget {
  /// Creates the confirmation of [plan].
  const CheckoutPage({required this.plan, super.key});

  /// The plan awaiting confirmation.
  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SubscriptionCubit>();
    final offer = context.read<PricingCatalog>().offerOf(plan);
    final l10n = context.l10n;

    return BlocSelector<SubscriptionCubit, SubscriptionState, bool>(
      selector: (state) => state is Processing,
      builder: (context, processing) => PopScope(
        canPop: !processing,
        child: SolennSheetScaffold(
          child: CheckoutView(
            planName: checkoutPlanName(plan, l10n),
            rows: checkoutRows(offer, l10n),
            dueToday: checkoutDueToday(offer),
            processing: processing,
            onConfirmPressed: cubit.confirmPurchase,
            onCancelPressed: cubit.cancelCheckout,
          ),
        ),
      ),
    );
  }
}
