import 'package:flutter/material.dart';

/// Corner radii. Keys, icon buttons and pills are fully circular and are
/// built with `StadiumBorder` or `CircleBorder` instead of a radius token.
@immutable
class SolennRadii extends ThemeExtension<SolennRadii> {
  /// Creates a radii set from explicit values.
  const SolennRadii({
    required this.displayCard,
    required this.sheet,
    required this.planCard,
    required this.banner,
    required this.chip,
  });

  /// The radii shipped with the application.
  static const SolennRadii standard = SolennRadii(
    displayCard: 28,
    sheet: 32,
    planCard: 24,
    banner: 20,
    chip: 12,
  );

  /// Calculator display card.
  final double displayCard;

  /// Top corners of sheets.
  final double sheet;

  /// Subscription plan cards.
  final double planCard;

  /// Banners.
  final double banner;

  /// Chips and badges.
  final double chip;

  @override
  SolennRadii copyWith({
    double? displayCard,
    double? sheet,
    double? planCard,
    double? banner,
    double? chip,
  }) {
    return SolennRadii(
      displayCard: displayCard ?? this.displayCard,
      sheet: sheet ?? this.sheet,
      planCard: planCard ?? this.planCard,
      banner: banner ?? this.banner,
      chip: chip ?? this.chip,
    );
  }

  /// Radii do not interpolate: the target wins past the midpoint.
  @override
  SolennRadii lerp(ThemeExtension<SolennRadii>? other, double t) {
    if (other is! SolennRadii) return this;
    return t < 0.5 ? this : other;
  }
}
