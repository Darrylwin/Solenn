import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/press_feedback.dart';
import 'package:solenn/core/design_system/components/solenn_pressable.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors.dart';

/// Visual role of a [SolennKey].
enum SolennKeyVariant {
  /// Dark gradient key carrying a digit.
  digit,

  /// Dark gradient key with a smaller label, such as the sign toggle.
  auxiliary,

  /// Gray key: clear, delete and percent.
  function,

  /// Accent key: operators and equals.
  accent,
}

const double _maxTextScale = 1.3;
const double _iconSize = 28;
const double _selectedRingWidth = 1.5;

// 160 degrees in CSS terms: mostly downward, slightly towards the right.
const Alignment _gradientBegin = Alignment(-0.342, -0.94);
const Alignment _gradientEnd = Alignment(0.342, 0.94);

/// A circular calculator key.
///
/// The key fills the square it is given. Press feedback follows the host
/// platform (see [SolennPressable]). Haptics are triggered by the caller
/// through [onPressStart], which fires on pointer down.
class SolennKey extends StatelessWidget {
  /// Creates a key showing either [label] or [icon].
  const SolennKey({
    required this.variant,
    required this.semanticLabel,
    this.label,
    this.icon,
    this.selected = false,
    this.onPressed,
    this.onPressStart,
    super.key,
  }) : assert(
         label != null || icon != null,
         'A key needs a label or an icon.',
       );

  /// Visual role of the key.
  final SolennKeyVariant variant;

  /// Spoken description of the key.
  final String semanticLabel;

  /// Visible text, used when [icon] is `null`.
  final String? label;

  /// Visible icon, which takes precedence over [label].
  final IconData? icon;

  /// Whether this accent key is the pending operator.
  final bool selected;

  /// Called when the key is tapped. A `null` value disables the key.
  final VoidCallback? onPressed;

  /// Called as soon as a pointer touches the key.
  final VoidCallback? onPressStart;

  bool get _enabled => onPressed != null;

  ShapeDecoration _decoration(SolennColors colors) {
    return switch (variant) {
      SolennKeyVariant.digit || SolennKeyVariant.auxiliary => ShapeDecoration(
        shape: const CircleBorder(),
        gradient: LinearGradient(
          begin: _gradientBegin,
          end: _gradientEnd,
          colors: [colors.keyDigitTop, colors.keyDigitBottom],
        ),
      ),
      SolennKeyVariant.function => ShapeDecoration(
        shape: const CircleBorder(),
        color: colors.keyFunction,
      ),
      SolennKeyVariant.accent when selected => ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(color: colors.accent, width: _selectedRingWidth),
        ),
        color: colors.onAccent,
      ),
      SolennKeyVariant.accent => ShapeDecoration(
        shape: const CircleBorder(),
        color: colors.accent,
      ),
    };
  }

  Color _foreground(SolennColors colors) {
    return switch (variant) {
      SolennKeyVariant.accent => selected ? colors.accent : colors.onAccent,
      _ => colors.textPrimary,
    };
  }

  Color _overlay(SolennColors colors) {
    final base = variant == SolennKeyVariant.accent && !selected
        ? colors.onAccent
        : colors.textPrimary;
    return base.withValues(alpha: solennPressOverlayAlpha);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final style = switch (variant) {
      SolennKeyVariant.digit => type.keyDigit,
      SolennKeyVariant.auxiliary ||
      SolennKeyVariant.function => type.keyFunction,
      SolennKeyVariant.accent => type.keyOperator,
    };

    return Semantics(
      button: true,
      enabled: _enabled,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: Opacity(
        opacity: _enabled ? 1 : solennDisabledOpacity,
        child: SolennPressable(
          shape: const CircleBorder(),
          decoration: _decoration(colors),
          overlayColor: _overlay(colors),
          onPressed: onPressed,
          onPressStart: onPressStart,
          child: Center(
            child: _KeyContent(
              label: label,
              icon: icon,
              style: style,
              color: _foreground(colors),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyContent extends StatelessWidget {
  const _KeyContent({
    required this.label,
    required this.icon,
    required this.style,
    required this.color,
  });

  final String? label;
  final IconData? icon;
  final TextStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    if (icon != null) {
      return Icon(icon, color: color, size: _iconSize);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label ?? '',
        maxLines: 1,
        textScaler: MediaQuery.textScalerOf(
          context,
        ).clamp(maxScaleFactor: _maxTextScale),
        style: style.copyWith(color: color),
      ),
    );
  }
}
