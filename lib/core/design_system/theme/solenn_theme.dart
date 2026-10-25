import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors_derived.dart';
import 'package:solenn/core/design_system/tokens/solenn_motion.dart';
import 'package:solenn/core/design_system/tokens/solenn_radii.dart';
import 'package:solenn/core/design_system/tokens/solenn_spacing.dart';
import 'package:solenn/core/design_system/tokens/solenn_typography.dart';

/// System bar styling: transparent bars with light content over the black
/// background. `statusBarBrightness` is the iOS counterpart of the icon
/// brightness settings, which Android reads.
const SystemUiOverlayStyle solennSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

/// Builds the only theme of the application (dark, see ADR-0008).
///
/// The platform is intentionally left to the framework so that behavior
/// follows the host OS (see section 12 of the specification).
ThemeData buildSolennTheme() {
  const colors = SolennColors.dark;
  const radii = SolennRadii.standard;

  final colorScheme = ColorScheme.dark(
    primary: colors.accent,
    onPrimary: colors.onAccent,
    secondary: colors.accent,
    onSecondary: colors.onAccent,
    surface: colors.surface,
    onSurface: colors.textPrimary,
    surfaceContainerHigh: colors.surfaceElevated,
    outline: colors.outline,
    error: colors.error,
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.background,
    fontFamily: solennFontFamily,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surfaceElevated,
      modalBackgroundColor: colors.surfaceElevated,
      modalBarrierColor: colors.scrim,
      showDragHandle: true,
      dragHandleColor: colors.sheetHandle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radii.sheet),
        ),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      colors,
      SolennTypography.standard,
      SolennSpacing.standard,
      radii,
      SolennMotion.defaults,
    ],
  );
}
