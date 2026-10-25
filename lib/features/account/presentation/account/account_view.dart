import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/l10n/l10n.dart';

const double _planMarkSize = 48;

/// The account screen.
///
/// A stateless consumer: the plan texts come from the caller, which knows the
/// subscription state, so this feature never depends on the subscription one.
class AccountView extends StatelessWidget {
  /// Creates the screen.
  const AccountView({
    required this.planName,
    required this.planDetail,
    required this.versionLabel,
    required this.onBackPressed,
    required this.onRestorePressed,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    required this.onLicensesPressed,
    this.planBadge,
    super.key,
  });

  /// Name of the current plan, for example `Solenn Plus`.
  final String planName;

  /// Second line of the plan card, for example `Annual · 7-day free trial`.
  final String planDetail;

  /// Version and build, for example `0.1.0 (1)`.
  final String versionLabel;

  /// Badge shown on the plan card, or `null` when there is none.
  final String? planBadge;

  /// Called when the back button is tapped.
  final VoidCallback onBackPressed;

  /// Called when Restore purchases is tapped.
  final VoidCallback onRestorePressed;

  /// Called when Terms of Service is tapped.
  final VoidCallback onTermsPressed;

  /// Called when Privacy Policy is tapped.
  final VoidCallback onPrivacyPressed;

  /// Called when Open-source licenses is tapped.
  final VoidCallback onLicensesPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return SolennPageScaffold(
      title: l10n.accountTitle,
      backSemanticLabel: l10n.backSemantics,
      onBackPressed: onBackPressed,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlanCard(name: planName, detail: planDetail, badge: planBadge),
            SizedBox(height: spacing.xxxl),
            _Section(
              caption: l10n.accountSectionSubscription,
              children: [
                SolennListTile(
                  title: l10n.accountRestorePurchases,
                  onPressed: onRestorePressed,
                ),
              ],
            ),
            _Section(
              caption: l10n.accountSectionLegal,
              children: [
                SolennListTile(
                  title: l10n.accountTerms,
                  onPressed: onTermsPressed,
                ),
                SolennListTile(
                  title: l10n.accountPrivacy,
                  onPressed: onPrivacyPressed,
                ),
                SolennListTile(
                  title: l10n.accountLicenses,
                  onPressed: onLicensesPressed,
                ),
              ],
            ),
            _Section(
              caption: l10n.accountSectionAbout,
              children: [
                SolennListTile(
                  title: l10n.accountVersion,
                  value: versionLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.detail,
    required this.badge,
  });

  final String name;
  final String detail;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final type = context.type;
    final badge = this.badge;

    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(context.radii.planCard),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xl,
            vertical: spacing.lg,
          ),
          child: Row(
            children: [
              SolennBrandMark(
                initial: context.l10n.brandInitial,
                size: _planMarkSize,
                shape: SolennBrandMarkShape.squircle,
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: type.titleMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      detail,
                      style: type.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: spacing.md),
                SolennChip(label: badge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.caption, required this.children});

  final String caption;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xxl - spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: spacing.sm,
                bottom: spacing.sm,
              ),
              child: Text(
                caption,
                style: context.type.caps.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
          SolennListGroup(children: children),
        ],
      ),
    );
  }
}
