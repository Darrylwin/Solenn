import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';
import 'package:solenn/core/platform/platform_style.dart';

/// A tappable surface whose press feedback follows the host platform.
///
/// - iOS: a veil of [overlayColor] fades in while the pointer is down. There
///   is no ripple.
/// - Android: an ink ripple clipped to [shape].
///
/// [onPressStart] fires on pointer down, before the tap completes, so haptics
/// can feel immediate. A `null` [onPressed] disables the surface entirely.
class SolennPressable extends StatefulWidget {
  /// Creates a pressable surface.
  const SolennPressable({
    required this.shape,
    required this.overlayColor,
    required this.child,
    this.decoration,
    this.onPressed,
    this.onPressStart,
    super.key,
  });

  /// Outline used to clip the ripple and the pressed veil.
  final ShapeBorder shape;

  /// Color of the pressed veil or of the ripple.
  final Color overlayColor;

  /// Background painted below the feedback. It must be a decoration of this
  /// widget (not of an ancestor) so that the ripple stays visible above it.
  final Decoration? decoration;

  /// Called when the surface is tapped. `null` disables the surface.
  final VoidCallback? onPressed;

  /// Called as soon as a pointer touches the surface.
  final VoidCallback? onPressStart;

  /// Content of the surface.
  final Widget child;

  @override
  State<SolennPressable> createState() => _SolennPressableState();
}

class _SolennPressableState extends State<SolennPressable> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed({required bool value}) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _setPressed(value: true);
    widget.onPressStart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final surface = context.usesCupertinoStyle
        ? _CupertinoSurface(
            shape: widget.shape,
            decoration: widget.decoration,
            overlayColor: widget.overlayColor,
            pressed: _pressed && _enabled,
            onPressed: widget.onPressed,
            child: widget.child,
          )
        : _MaterialSurface(
            shape: widget.shape,
            decoration: widget.decoration,
            overlayColor: widget.overlayColor,
            onPressed: widget.onPressed,
            child: widget.child,
          );

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _enabled ? _handlePointerDown : null,
      onPointerUp: (_) => _setPressed(value: false),
      onPointerCancel: (_) => _setPressed(value: false),
      child: surface,
    );
  }
}

class _MaterialSurface extends StatelessWidget {
  const _MaterialSurface({
    required this.shape,
    required this.decoration,
    required this.overlayColor,
    required this.onPressed,
    required this.child,
  });

  final ShapeBorder shape;
  final Decoration? decoration;
  final Color overlayColor;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ripple = InkWell(
      customBorder: shape,
      splashColor: overlayColor,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: child,
    );
    final decoration = this.decoration;

    return Material(
      type: MaterialType.transparency,
      child: decoration == null
          ? ripple
          : Ink(decoration: decoration, child: ripple),
    );
  }
}

class _CupertinoSurface extends StatelessWidget {
  const _CupertinoSurface({
    required this.shape,
    required this.decoration,
    required this.overlayColor,
    required this.pressed,
    required this.onPressed,
    required this.child,
  });

  final ShapeBorder shape;
  final Decoration? decoration;
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
        children: [
          DecoratedBox(
            decoration: decoration ?? const BoxDecoration(),
            child: child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: context.motion.press,
                curve: context.motion.standard,
                decoration: ShapeDecoration(
                  shape: shape,
                  color: pressed ? overlayColor : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
