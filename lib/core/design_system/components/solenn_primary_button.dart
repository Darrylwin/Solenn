import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/press_feedback.dart';
import 'package:solenn/core/design_system/components/solenn_pressable.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';
import 'package:solenn/core/platform/platform_style.dart';

/// Height of the primary button.
const double solennButtonHeight = 60;

const double _spinnerSize = 22;
const double _spinnerStrokeWidth = 2.5;

/// The full-width pill button for the main action of a screen.
///
/// While [loading], the label keeps its space (so the width does not jump), a
/// spinner replaces it, and taps are ignored.
class SolennPrimaryButton extends StatelessWidget {
  /// Creates a primary button. A `null` [onPressed] disables it.
  const SolennPrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.onPressStart,
    super.key,
  });

  /// Visible and spoken label.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Whether the action is in progress.
  final bool loading;

  /// Called as soon as a pointer touches the button.
  final VoidCallback? onPressStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final enabled = onPressed != null && !loading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: enabled ? onPressed : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: onPressed == null ? solennDisabledOpacity : 1,
        child: SizedBox(
          height: solennButtonHeight,
          width: double.infinity,
          child: SolennPressable(
            shape: const StadiumBorder(),
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: colors.accent,
            ),
            overlayColor: colors.onAccent.withValues(
              alpha: solennPressOverlayAlpha,
            ),
            onPressed: enabled ? onPressed : null,
            onPressStart: enabled ? onPressStart : null,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: loading ? 0 : 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: context.type.cta.copyWith(
                            color: colors.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (loading) _Spinner(color: colors.onAccent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    if (context.usesCupertinoStyle) {
      return CupertinoActivityIndicator(color: color);
    }
    return SizedBox.square(
      dimension: _spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: _spinnerStrokeWidth,
        color: color,
      ),
    );
  }
}
