import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/press_feedback.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';
import 'package:solenn/core/platform/platform.dart';

const double _iconSize = 22;

/// A 44 x 44 circular icon button on the surface color.
class SolennIconButton extends StatelessWidget {
  /// Creates an icon button. A `null` [onPressed] disables it.
  const SolennIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    super.key,
  });

  /// The icon to draw.
  final IconData icon;

  /// Spoken description of the button.
  final String semanticLabel;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final cupertino = context.usesCupertinoStyle;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : solennDisabledOpacity,
        child: SizedBox.square(
          dimension: context.spacing.minTouchTarget,
          child: Material(
            color: colors.surface,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              splashFactory: cupertino ? NoSplash.splashFactory : null,
              highlightColor: cupertino
                  ? colors.textPrimary.withValues(
                      alpha: solennPressOverlayAlpha,
                    )
                  : null,
              child: Center(
                child: Icon(icon, size: _iconSize, color: colors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
