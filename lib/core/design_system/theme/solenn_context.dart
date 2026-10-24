import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors.dart';
import 'package:solenn/core/design_system/tokens/solenn_motion.dart';
import 'package:solenn/core/design_system/tokens/solenn_radii.dart';
import 'package:solenn/core/design_system/tokens/solenn_spacing.dart';
import 'package:solenn/core/design_system/tokens/solenn_typography.dart';

/// Access to the Solenn design tokens from any [BuildContext].
///
/// Each getter throws if the Solenn theme is not installed, which is the
/// desired behavior: a missing theme is a programming error.
extension SolennContext on BuildContext {
  /// Color tokens.
  SolennColors get colors => Theme.of(this).extension<SolennColors>()!;

  /// Text styles.
  SolennTypography get type => Theme.of(this).extension<SolennTypography>()!;

  /// Spacing and layout constants.
  SolennSpacing get spacing => Theme.of(this).extension<SolennSpacing>()!;

  /// Corner radii.
  SolennRadii get radii => Theme.of(this).extension<SolennRadii>()!;

  /// Durations and curves.
  SolennMotion get motion => Theme.of(this).extension<SolennMotion>()!;
}
