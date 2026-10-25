import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/press_feedback.dart';
import 'package:solenn/core/design_system/components/solenn_pressable.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

/// Size of the label of a [SolennTextButton].
enum SolennTextButtonSize {
  /// Body-sized label, for secondary actions such as a decline link.
  regular,

  /// Small label, for footer links.
  small,
}

/// A borderless text button on the secondary text color.
///
/// The visible label can be small; the touch target is never smaller than the
/// minimum target of the design system.
class SolennTextButton extends StatelessWidget {
  /// Creates a text button. A `null` [onPressed] disables it.
  const SolennTextButton({
    required this.label,
    required this.onPressed,
    this.size = SolennTextButtonSize.regular,
    this.onPressStart,
    super.key,
  });

  /// Visible and spoken label.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Size of the label.
  final SolennTextButtonSize size;

  /// Called as soon as a pointer touches the button.
  final VoidCallback? onPressStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final type = context.type;
    final base = switch (size) {
      SolennTextButtonSize.regular => type.body.copyWith(
        fontWeight: FontWeight.w500,
      ),
      SolennTextButtonSize.small => type.label,
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: Opacity(
        opacity: onPressed == null ? solennDisabledOpacity : 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: spacing.minTouchTarget,
            minHeight: spacing.minTouchTarget,
          ),
          child: SolennPressable(
            shape: const StadiumBorder(),
            overlayColor: colors.textPrimary.withValues(
              alpha: solennPressOverlayAlpha,
            ),
            onPressed: onPressed,
            onPressStart: onPressStart,
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: base.copyWith(color: colors.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
