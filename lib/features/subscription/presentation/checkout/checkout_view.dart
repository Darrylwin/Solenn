import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_row.dart';
import 'package:solenn/l10n/l10n.dart';

const double _productMarkSize = 56;
const double _dueTodaySize = 22;

/// Content of the purchase confirmation sheet.
///
/// It contains no text field (constraint C1). The caller presents it inside a
/// `SolennSheetScaffold` through `showSolennSheet` and decides whether the
/// sheet can be dismissed while [processing].
class CheckoutView extends StatelessWidget {
  /// Creates the confirmation content.
  const CheckoutView({
    required this.planName,
    required this.rows,
    required this.dueToday,
    required this.onConfirmPressed,
    required this.onCancelPressed,
    this.processing = false,
    super.key,
  });

  /// Name of the chosen plan, for example `Annual subscription`.
  final String planName;

  /// Summary lines shown above the amount due.
  final List<CheckoutRow> rows;

  /// Formatted amount charged now.
  final String dueToday;

  /// Called when Confirm is tapped.
  final VoidCallback onConfirmPressed;

  /// Called when Cancel is tapped.
  final VoidCallback onCancelPressed;

  /// Whether the purchase is being processed.
  final bool processing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final type = context.type;
    final haptics = context.read<HapticsService>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SolennBrandMark(
              initial: l10n.brandInitial,
              size: _productMarkSize,
              shape: SolennBrandMarkShape.squircle,
            ),
            SizedBox(width: spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.checkoutProductName,
                    style: type.titleLarge.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    planName,
                    style: type.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.lg),
        for (final row in rows) _SummaryRow(label: row.label, value: row.value),
        _SummaryRow(
          label: l10n.checkoutDueToday,
          value: dueToday,
          emphasized: true,
          showDivider: false,
        ),
        SizedBox(height: spacing.lg),
        SolennPrimaryButton(
          label: l10n.checkoutConfirm,
          loading: processing,
          onPressed: onConfirmPressed,
          onPressStart: haptics.medium,
        ),
        SizedBox(height: spacing.sm),
        Center(
          child: SolennTextButton(
            label: l10n.checkoutCancel,
            onPressed: processing ? null : onCancelPressed,
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          l10n.checkoutRenewalNotice,
          textAlign: TextAlign.center,
          style: type.label.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final type = context.type;

    final labelStyle = emphasized
        ? type.titleMedium.copyWith(color: colors.textPrimary)
        : type.body.copyWith(color: colors.textSecondary);
    final valueStyle = emphasized
        ? type.price.copyWith(fontSize: _dueTodaySize, color: colors.accent)
        : type.body.copyWith(color: colors.textPrimary);

    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: colors.outline,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.md),
          child: Row(
            children: [
              Expanded(child: Text(label, style: labelStyle)),
              SizedBox(width: spacing.md),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: valueStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
