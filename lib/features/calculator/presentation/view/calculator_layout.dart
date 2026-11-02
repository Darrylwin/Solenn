import 'dart:math' as math;

import 'package:solenn/core/design_system/design_system.dart';

/// Smallest display card height the layout aims to keep.
const double calculatorMinDisplayHeight = 140;

/// Tallest display card. On taller screens the extra space goes above the
/// card, which stays anchored to the keypad.
const double calculatorMaxDisplayHeight = 220;

/// Vertical space reserved for the banner slot when a banner is shown.
const double calculatorBannerAllowance = 88;

/// Diameter the keys would have if only the height limited them, before the
/// minimum touch target is applied. It can be below that minimum.
double _keyDiameterByHeight({
  required SolennSpacing spacing,
  required double height,
  required bool hasBanner,
}) {
  final reserved =
      spacing.minTouchTarget +
      spacing.xl +
      calculatorMinDisplayHeight +
      spacing.xxl +
      spacing.md +
      (hasBanner ? calculatorBannerAllowance : 0);
  return (height - reserved - 4 * spacing.keyGap) / 5;
}

/// Whether a banner fits in [height] without shrinking the keys below the
/// minimum touch target.
///
/// On very short screens the banner is skipped: it is decorative and
/// temporary, while squeezing it in would crush the display.
bool calculatorBannerFits({
  required SolennSpacing spacing,
  required double height,
}) =>
    _keyDiameterByHeight(spacing: spacing, height: height, hasBanner: true) >=
    spacing.minTouchTarget;

/// Diameter of the keypad keys for a content area of [width] x [height].
///
/// Keys are limited by the width (four columns) and by the height left once
/// the header, the banner allowance and the minimum display are reserved, so
/// small phones shrink the keypad instead of overflowing. They never drop
/// below the minimum touch target.
double calculatorKeyDiameter({
  required SolennSpacing spacing,
  required double width,
  required double height,
  required bool hasBanner,
}) {
  final byWidth = (width - 3 * spacing.keyGap) / 4;
  final byHeight = _keyDiameterByHeight(
    spacing: spacing,
    height: height,
    hasBanner: hasBanner,
  );
  return math.max(spacing.minTouchTarget, math.min(byWidth, byHeight));
}
