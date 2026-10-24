import 'package:flutter/material.dart';

/// Durations and curves shared by every animation.
@immutable
class SolennMotion extends ThemeExtension<SolennMotion> {
  /// Creates a motion set from explicit values.
  const SolennMotion({
    required this.press,
    required this.fast,
    required this.base,
    required this.slow,
    required this.standard,
    required this.emphasized,
  });

  /// The motion set shipped with the application.
  static const SolennMotion defaults = SolennMotion(
    press: Duration(milliseconds: 80),
    fast: Duration(milliseconds: 160),
    base: Duration(milliseconds: 240),
    slow: Duration(milliseconds: 360),
    standard: Curves.easeOutCubic,
    emphasized: Cubic(0.2, 0, 0, 1),
  );

  /// Key press feedback.
  final Duration press;

  /// Selection and small state changes.
  final Duration fast;

  /// General transitions.
  final Duration base;

  /// Large entrances such as the paywall.
  final Duration slow;

  /// Default curve.
  final Curve standard;

  /// Curve for entrances and exits of large surfaces.
  final Curve emphasized;

  @override
  SolennMotion copyWith({
    Duration? press,
    Duration? fast,
    Duration? base,
    Duration? slow,
    Curve? standard,
    Curve? emphasized,
  }) {
    return SolennMotion(
      press: press ?? this.press,
      fast: fast ?? this.fast,
      base: base ?? this.base,
      slow: slow ?? this.slow,
      standard: standard ?? this.standard,
      emphasized: emphasized ?? this.emphasized,
    );
  }

  /// Motion tokens do not interpolate: the target wins past the midpoint.
  @override
  SolennMotion lerp(ThemeExtension<SolennMotion>? other, double t) {
    if (other is! SolennMotion) return this;
    return t < 0.5 ? this : other;
  }
}
