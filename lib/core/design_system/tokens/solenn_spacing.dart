import 'package:flutter/material.dart';

/// Spacing scale (4-point grid) and layout constants.
@immutable
class SolennSpacing extends ThemeExtension<SolennSpacing> {
  /// Creates a spacing scale from explicit values.
  const SolennSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.huge,
    required this.screenMargin,
    required this.keyGap,
    required this.maxContentWidth,
    required this.minTouchTarget,
  });

  /// The scale shipped with the application.
  static const SolennSpacing standard = SolennSpacing(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
    xxl: 24,
    xxxl: 32,
    huge: 40,
    screenMargin: 24,
    keyGap: 12,
    maxContentWidth: 430,
    minTouchTarget: 44,
  );

  /// 4 logical pixels.
  final double xs;

  /// 8 logical pixels.
  final double sm;

  /// 12 logical pixels.
  final double md;

  /// 16 logical pixels.
  final double lg;

  /// 20 logical pixels.
  final double xl;

  /// 24 logical pixels.
  final double xxl;

  /// 32 logical pixels.
  final double xxxl;

  /// 40 logical pixels.
  final double huge;

  /// Horizontal margin of screens.
  final double screenMargin;

  /// Gap between keypad keys.
  final double keyGap;

  /// Maximum width of the centered content column.
  final double maxContentWidth;

  /// Minimum size of any interactive target.
  final double minTouchTarget;

  @override
  SolennSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? huge,
    double? screenMargin,
    double? keyGap,
    double? maxContentWidth,
    double? minTouchTarget,
  }) {
    return SolennSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      huge: huge ?? this.huge,
      screenMargin: screenMargin ?? this.screenMargin,
      keyGap: keyGap ?? this.keyGap,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
    );
  }

  /// Layout constants do not interpolate: the target wins past the midpoint.
  @override
  SolennSpacing lerp(ThemeExtension<SolennSpacing>? other, double t) {
    if (other is! SolennSpacing) return this;
    return t < 0.5 ? this : other;
  }
}
