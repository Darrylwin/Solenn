import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/design_system/components/solenn_plan_card.dart';
import 'package:solenn/core/design_system/components/solenn_pressable.dart';
import 'package:solenn/core/design_system/components/solenn_primary_button.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_fine_print.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_plan_option.dart';
import 'package:solenn/l10n/l10n.dart';

const double _brandMarkSize = 28;
const double _closeIconSize = 18;
const double _subtitleMaxWidth = 300;
const double _starSize = 14;
const int _starCount = 5;

/// The full-screen paywall.
///
/// A stateless consumer: it renders display strings and reports intent.
/// Every exit (close, decline, restore, system back) is a separate callback so
/// that the layer above can map each to its own dismissal reason.
class PaywallView extends StatelessWidget {
  /// Creates the paywall.
  const PaywallView({
    required this.plans,
    required this.selectedPlanId,
    required this.ctaLabel,
    required this.finePrint,
    required this.socialProofCount,
    required this.onPlanSelected,
    required this.onPurchasePressed,
    required this.onClosePressed,
    required this.onDeclinePressed,
    required this.onRestorePressed,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    required this.onSystemBackPressed,
    super.key,
  });

  /// Plans offered, in display order.
  final List<PaywallPlanOption> plans;

  /// Identifier of the selected plan.
  final String selectedPlanId;

  /// Label of the main button, which depends on the selected plan.
  final String ctaLabel;

  /// Price reminder shown under the main button.
  final String finePrint;

  /// Number displayed in the social proof line.
  final int socialProofCount;

  /// Called with the identifier of the tapped plan.
  final ValueChanged<String> onPlanSelected;

  /// Called when the main button is tapped.
  final VoidCallback onPurchasePressed;

  /// Called when the close button is tapped.
  final VoidCallback onClosePressed;

  /// Called when the decline link is tapped.
  final VoidCallback onDeclinePressed;

  /// Called when Restore is tapped.
  final VoidCallback onRestorePressed;

  /// Called when Terms is tapped.
  final VoidCallback onTermsPressed;

  /// Called when Privacy is tapped.
  final VoidCallback onPrivacyPressed;

  /// Called when the system back gesture or button is used.
  final VoidCallback onSystemBackPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final haptics = context.read<HapticsService>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onSystemBackPressed();
      },
      child: Scaffold(
        body: SafeArea(
          minimum: EdgeInsets.fromLTRB(
            spacing.screenMargin,
            spacing.sm,
            spacing.screenMargin,
            spacing.lg,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: spacing.maxContentWidth,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(onClosePressed: onClosePressed),
                          SizedBox(height: spacing.xxl),
                          const _Hero(),
                          SizedBox(height: spacing.lg),
                          _SocialProof(count: socialProofCount),
                          SizedBox(height: spacing.xxxl),
                          _PlanList(
                            plans: plans,
                            selectedPlanId: selectedPlanId,
                            onPlanSelected: onPlanSelected,
                            haptics: haptics,
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: spacing.xxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SolennPrimaryButton(
                              label: ctaLabel,
                              onPressed: onPurchasePressed,
                              onPressStart: haptics.light,
                            ),
                            SizedBox(height: spacing.md),
                            PaywallFinePrint(text: finePrint),
                            SizedBox(height: spacing.sm),
                            Center(
                              child: SolennTextButton(
                                label: context.l10n.paywallDecline,
                                onPressed: onDeclinePressed,
                              ),
                            ),
                            _Footer(
                              onRestorePressed: onRestorePressed,
                              onTermsPressed: onTermsPressed,
                              onPrivacyPressed: onPrivacyPressed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClosePressed});

  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SolennBrandMark(
                    initial: l10n.brandInitial,
                    size: _brandMarkSize,
                  ),
                  SizedBox(width: spacing.md),
                  Text.rich(
                    TextSpan(
                      style: context.type.titleMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      children: [
                        TextSpan(text: l10n.paywallBrandName),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: l10n.paywallBrandTier,
                          style: context.type.titleMedium.copyWith(
                            color: colors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _CloseButton(onPressed: onClosePressed),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: context.l10n.paywallCloseSemantics,
      onTap: onPressed,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: context.spacing.minTouchTarget,
        child: SolennPressable(
          shape: const CircleBorder(),
          overlayColor: colors.textPrimary.withValues(
            alpha: solennPressOverlayAlpha,
          ),
          onPressed: onPressed,
          child: Center(
            child: Icon(
              Icons.close_rounded,
              size: _closeIconSize,
              color: colors.iconMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final style = context.type.heroTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text.rich(
              TextSpan(
                style: style.copyWith(color: colors.textPrimary),
                children: [
                  TextSpan(text: '${l10n.paywallTitleLead}\n'),
                  TextSpan(
                    text: l10n.paywallTitleAccent,
                    style: style.copyWith(color: colors.accent),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _subtitleMaxWidth),
            child: Text(
              l10n.paywallSubtitle,
              style: context.type.body.copyWith(color: colors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialProof extends StatelessWidget {
  const _SocialProof({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var star = 0; star < _starCount; star++)
                Icon(Icons.star_rounded, size: _starSize, color: colors.accent),
            ],
          ),
        ),
        Text(
          context.l10n.paywallSocialProof(count),
          style: context.type.label.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.plans,
    required this.selectedPlanId,
    required this.onPlanSelected,
    required this.haptics,
  });

  final List<PaywallPlanOption> plans;
  final String selectedPlanId;
  final ValueChanged<String> onPlanSelected;
  final HapticsService haptics;

  @override
  Widget build(BuildContext context) {
    final gap = context.spacing.md;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < plans.length; index++) ...[
          if (index > 0) SizedBox(height: gap),
          SolennPlanCard(
            title: plans[index].title,
            subtitle: plans[index].subtitle,
            price: plans[index].price,
            anchorPrice: plans[index].anchorPrice,
            badge: plans[index].badge,
            dense: plans[index].dense,
            selected: plans[index].id == selectedPlanId,
            semanticLabel: plans[index].semanticLabel,
            onPressStart: haptics.selection,
            onPressed: () => onPlanSelected(plans[index].id),
          ),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.onRestorePressed,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  final VoidCallback onRestorePressed;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        SolennTextButton(
          label: l10n.paywallRestore,
          size: SolennTextButtonSize.small,
          onPressed: onRestorePressed,
        ),
        SolennTextButton(
          label: l10n.paywallTerms,
          size: SolennTextButtonSize.small,
          onPressed: onTermsPressed,
        ),
        SolennTextButton(
          label: l10n.paywallPrivacy,
          size: SolennTextButtonSize.small,
          onPressed: onPrivacyPressed,
        ),
      ],
    );
  }
}
