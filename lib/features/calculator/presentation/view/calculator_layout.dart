import 'dart:math' as math;

import 'package:solenn/core/design_system/design_system.dart';

/// Smallest display card height the layout aims to keep.
const double calculatorMinDisplayHeight = 140;

/// Vertical space reserved for the banner slot when a banner is shown.
const double calculatorBannerAllowance = 88;

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
  final gap = spacing.keyGap;
  final byWidth = (width - 3 * gap) / 4;
  final reserved =
      spacing.minTouchTarget +
      spacing.xl +
      calculatorMinDisplayHeight +
      spacing.xxl +
      (hasBanner ? calculatorBannerAllowance : 0);
  final byHeight = (height - reserved - 4 * gap) / 5;
  return math.max(spacing.minTouchTarget, math.min(byWidth, byHeight));
}
