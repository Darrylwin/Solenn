import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

/// Widths at which screens and components are captured (specification 16.1).
const List<double> goldenWidths = [320, 390, 430];

/// Key of the boundary that [goldenGallery] draws, and that
/// [expectBoundaryGolden] captures.
const Key goldenBoundaryKey = Key('golden.boundary');

/// A phone-shaped window of [width]: the narrowest and the widest of
/// [goldenWidths] get the height of a small and of a large phone.
Size phoneSize(double width) {
  if (width <= 320) return Size(width, 568);
  if (width >= 430) return Size(width, 932);
  return Size(width, 844);
}

/// The file name (without extension) of the golden of [base] at [width], with
/// the platform when the visuals differ between iOS and Android.
String goldenName(String base, double width, {TargetPlatform? platform}) {
  final suffix = platform == null ? '' : '-${platform.name.toLowerCase()}';
  return '$base-${width.toInt()}$suffix';
}

/// Wraps [child] so that it is drawn on the app background, at its own size,
/// and can be captured alone with [expectBoundaryGolden].
///
/// The Material ancestor gives text its default style. [width] fixes the
/// width the content lays out in, for components that follow it.
Widget goldenGallery(Widget child, {double? width}) {
  return Align(
    alignment: Alignment.topLeft,
    child: RepaintBoundary(
      key: goldenBoundaryKey,
      child: Material(
        color: SolennColors.dark.background,
        child: width == null ? child : SizedBox(width: width, child: child),
      ),
    ),
  );
}

/// Compares the whole screen with `goldens/[name].png`, next to the test file.
Future<void> expectScreenGolden(String name) => expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('goldens/$name.png'),
);

/// Compares the boundary of [goldenGallery] with `goldens/[name].png`.
Future<void> expectBoundaryGolden(String name) => expectLater(
  find.byKey(goldenBoundaryKey),
  matchesGoldenFile('goldens/$name.png'),
);
