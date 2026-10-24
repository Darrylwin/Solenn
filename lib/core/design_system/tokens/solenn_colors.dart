import 'package:flutter/material.dart';

/// Color tokens of the Solenn palette.
///
/// Solenn ships a single dark palette (ADR-0008). Every color of the
/// interface comes from here; hex literals are forbidden elsewhere.
@immutable
class SolennColors extends ThemeExtension<SolennColors> {
  /// Creates a palette from explicit values.
  const SolennColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.outline,
    required this.keyDigitTop,
    required this.keyDigitBottom,
    required this.keyFunction,
    required this.accent,
    required this.onAccent,
    required this.accentMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconMuted,
    required this.scrim,
    required this.error,
  });

  /// The palette shipped with the application.
  static const SolennColors dark = SolennColors(
    background: Color(0xFF000000),
    surface: Color(0xFF141414),
    surfaceElevated: Color(0xFF161616),
    outline: Color(0xFF2A2A2A),
    keyDigitTop: Color(0xFF262626),
    keyDigitBottom: Color(0xFF0C0C0C),
    keyFunction: Color(0xFF5B5B5B),
    accent: Color(0xFFE4FF4F),
    onAccent: Color(0xFF0A0A0A),
    accentMuted: Color(0xFF2F3318),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFF9A9A9A),
    iconMuted: Color(0xFF6B6B6B),
    scrim: Color(0x8C000000),
    error: Color(0xFFFF6B6B),
  );

  /// Screen background.
  final Color background;

  /// Cards, icon buttons and banners.
  final Color surface;

  /// Sheets and popovers.
  final Color surfaceElevated;

  /// Hairlines, unselected borders and dividers.
  final Color outline;

  /// Top stop of the digit key gradient.
  final Color keyDigitTop;

  /// Bottom stop of the digit key gradient.
  final Color keyDigitBottom;

  /// Function keys (AC, backspace, percent).
  final Color keyFunction;

  /// Operators, primary actions and selection.
  final Color accent;

  /// Content drawn on top of [accent].
  final Color onAccent;

  /// Accent-tinted borders.
  final Color accentMuted;

  /// Primary text.
  final Color textPrimary;

  /// Secondary text and captions.
  final Color textSecondary;

  /// Non-text icons only; it does not meet text contrast.
  final Color iconMuted;

  /// Barrier drawn behind sheets.
  final Color scrim;

  /// Satisfies the Material error slot; unused by the interface.
  final Color error;

  @override
  SolennColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? outline,
    Color? keyDigitTop,
    Color? keyDigitBottom,
    Color? keyFunction,
    Color? accent,
    Color? onAccent,
    Color? accentMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? iconMuted,
    Color? scrim,
    Color? error,
  }) {
    return SolennColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      outline: outline ?? this.outline,
      keyDigitTop: keyDigitTop ?? this.keyDigitTop,
      keyDigitBottom: keyDigitBottom ?? this.keyDigitBottom,
      keyFunction: keyFunction ?? this.keyFunction,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentMuted: accentMuted ?? this.accentMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      iconMuted: iconMuted ?? this.iconMuted,
      scrim: scrim ?? this.scrim,
      error: error ?? this.error,
    );
  }

  @override
  SolennColors lerp(ThemeExtension<SolennColors>? other, double t) {
    if (other is! SolennColors) return this;
    return SolennColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      keyDigitTop: Color.lerp(keyDigitTop, other.keyDigitTop, t)!,
      keyDigitBottom: Color.lerp(keyDigitBottom, other.keyDigitBottom, t)!,
      keyFunction: Color.lerp(keyFunction, other.keyFunction, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
