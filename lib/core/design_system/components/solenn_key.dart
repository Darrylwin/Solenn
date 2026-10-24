import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/press_feedback.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors.dart';
import 'package:solenn/core/platform/platform.dart';

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
/// platform: a brightening fill on iOS, an ink ripple on Android. Haptics are
/// triggered by the caller through [onPressStart], which fires on pointer
/// down so that feedback feels immediate.
class SolennKey extends StatefulWidget {
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

  @override
  State<SolennKey> createState() => _SolennKeyState();
}

class _SolennKeyState extends State<SolennKey> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _setPressed(true);
    widget.onPressStart?.call();
  }

  ShapeDecoration _decoration(SolennColors colors) {
    return switch (widget.variant) {
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
      SolennKeyVariant.accent when widget.selected => ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: colors.accent,
            width: _selectedRingWidth,
          ),
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
    return switch (widget.variant) {
      SolennKeyVariant.accent =>
        widget.selected ? colors.accent : colors.onAccent,
      _ => colors.textPrimary,
    };
  }

  Color _overlay(SolennColors colors) {
    final base = widget.variant == SolennKeyVariant.accent && !widget.selected
        ? colors.onAccent
        : colors.textPrimary;
    return base.withValues(alpha: solennPressOverlayAlpha);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final style = switch (widget.variant) {
      SolennKeyVariant.digit => type.keyDigit,
      SolennKeyVariant.auxiliary ||
      SolennKeyVariant.function => type.keyFunction,
      SolennKeyVariant.accent => type.keyOperator,
    };

    final content = Center(
      child: _KeyContent(
        label: widget.label,
        icon: widget.icon,
        style: style,
        color: _foreground(colors),
      ),
    );

    final surface = context.usesCupertinoStyle
        ? _CupertinoPressSurface(
            decoration: _decoration(colors),
            overlayColor: _overlay(colors),
            pressed: _pressed,
            onPressed: widget.onPressed,
            child: content,
          )
        : _MaterialPressSurface(
            decoration: _decoration(colors),
            splashColor: _overlay(colors),
            onPressed: widget.onPressed,
            child: content,
          );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: Opacity(
        opacity: _enabled ? 1 : solennDisabledOpacity,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _enabled ? _handlePointerDown : null,
          onPointerUp: (_) => _setPressed(false),
          onPointerCancel: (_) => _setPressed(false),
          child: surface,
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

class _MaterialPressSurface extends StatelessWidget {
  const _MaterialPressSurface({
    required this.decoration,
    required this.splashColor,
    required this.onPressed,
    required this.child,
  });

  final ShapeDecoration decoration;
  final Color splashColor;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: splashColor,
          highlightColor: Colors.transparent,
          onTap: onPressed,
          child: child,
        ),
      ),
    );
  }
}

class _CupertinoPressSurface extends StatelessWidget {
  const _CupertinoPressSurface({
    required this.decoration,
    required this.overlayColor,
    required this.pressed,
    required this.onPressed,
    required this.child,
  });

  final ShapeDecoration decoration;
  final Color overlayColor;
  final bool pressed;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: decoration, child: child),
          IgnorePointer(
            child: AnimatedContainer(
              duration: context.motion.press,
              curve: context.motion.standard,
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: pressed ? overlayColor : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
