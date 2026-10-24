import 'package:flutter/material.dart';

/// Family name of the bundled brand typeface (see `pubspec.yaml`).
const String solennFontFamily = 'Manrope';

/// Text styles of the Solenn type scale.
///
/// Styles carry no color; components apply it from `SolennColors`.
@immutable
class SolennTypography extends ThemeExtension<SolennTypography> {
  /// Creates a type scale from explicit styles.
  const SolennTypography({
    required this.displayResult,
    required this.displayExpression,
    required this.keyDigit,
    required this.keyFunction,
    required this.keyOperator,
    required this.heroTitle,
    required this.titleLarge,
    required this.titleMedium,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.caps,
    required this.price,
    required this.cta,
  });

  /// The scale shipped with the application.
  static const SolennTypography standard = SolennTypography(
    displayResult: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 64,
      fontWeight: FontWeight.w300,
      letterSpacing: -2,
      fontFeatures: _tabular,
    ),
    displayExpression: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w300,
      fontFeatures: _tabular,
    ),
    keyDigit: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w300,
    ),
    keyFunction: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    keyOperator: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 34,
      fontWeight: FontWeight.w400,
    ),
    heroTitle: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 46,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      height: 1.04,
    ),
    titleLarge: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 19,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    body: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    bodySmall: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
    ),
    label: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    caps: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    ),
    price: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFeatures: _tabular,
    ),
    cta: TextStyle(
      fontFamily: solennFontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  );

  /// Tabular figures keep digits aligned while values change.
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Calculator result line.
  final TextStyle displayResult;

  /// Calculator expression line.
  final TextStyle displayExpression;

  /// Digit keys.
  final TextStyle keyDigit;

  /// Function keys.
  final TextStyle keyFunction;

  /// Operator keys.
  final TextStyle keyOperator;

  /// Large titles such as the paywall headline.
  final TextStyle heroTitle;

  /// Prominent titles.
  final TextStyle titleLarge;

  /// Secondary titles.
  final TextStyle titleMedium;

  /// Regular body copy.
  final TextStyle body;

  /// Small body copy and captions.
  final TextStyle bodySmall;

  /// Small labels.
  final TextStyle label;

  /// Uppercase badges.
  final TextStyle caps;

  /// Prices.
  final TextStyle price;

  /// Primary call to action.
  final TextStyle cta;

  @override
  SolennTypography copyWith({
    TextStyle? displayResult,
    TextStyle? displayExpression,
    TextStyle? keyDigit,
    TextStyle? keyFunction,
    TextStyle? keyOperator,
    TextStyle? heroTitle,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? caps,
    TextStyle? price,
    TextStyle? cta,
  }) {
    return SolennTypography(
      displayResult: displayResult ?? this.displayResult,
      displayExpression: displayExpression ?? this.displayExpression,
      keyDigit: keyDigit ?? this.keyDigit,
      keyFunction: keyFunction ?? this.keyFunction,
      keyOperator: keyOperator ?? this.keyOperator,
      heroTitle: heroTitle ?? this.heroTitle,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      caps: caps ?? this.caps,
      price: price ?? this.price,
      cta: cta ?? this.cta,
    );
  }

  @override
  SolennTypography lerp(ThemeExtension<SolennTypography>? other, double t) {
    if (other is! SolennTypography) return this;
    return SolennTypography(
      displayResult: TextStyle.lerp(displayResult, other.displayResult, t)!,
      displayExpression: TextStyle.lerp(
        displayExpression,
        other.displayExpression,
        t,
      )!,
      keyDigit: TextStyle.lerp(keyDigit, other.keyDigit, t)!,
      keyFunction: TextStyle.lerp(keyFunction, other.keyFunction, t)!,
      keyOperator: TextStyle.lerp(keyOperator, other.keyOperator, t)!,
      heroTitle: TextStyle.lerp(heroTitle, other.heroTitle, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caps: TextStyle.lerp(caps, other.caps, t)!,
      price: TextStyle.lerp(price, other.price, t)!,
      cta: TextStyle.lerp(cta, other.cta, t)!,
    );
  }
}
