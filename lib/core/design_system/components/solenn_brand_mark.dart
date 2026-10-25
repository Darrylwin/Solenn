import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

/// Outline of a [SolennBrandMark].
enum SolennBrandMarkShape {
  /// A circle, used in headers.
  circle,

  /// A rounded square, used as an app-icon stand-in.
  squircle,
}

const double _squircleRadiusRatio = 0.28;
const double _initialSizeRatio = 0.5;

/// Placeholder brand mark: an accent shape with the product initial.
///
/// Decorative only, so it is hidden from screen readers. The final artwork
/// replaces this widget without changing its callers.
class SolennBrandMark extends StatelessWidget {
  /// Creates a mark of [size] logical pixels showing [initial].
  const SolennBrandMark({
    required this.initial,
    required this.size,
    this.shape = SolennBrandMarkShape.circle,
    super.key,
  });

  /// Letter drawn inside the mark.
  final String initial;

  /// Width and height of the mark.
  final double size;

  /// Outline of the mark.
  final SolennBrandMarkShape shape;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final outline = switch (shape) {
      SolennBrandMarkShape.circle => const CircleBorder(),
      SolennBrandMarkShape.squircle => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size * _squircleRadiusRatio),
      ),
    };

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: ShapeDecoration(color: colors.accent, shape: outline),
          child: Center(
            child: Text(
              initial,
              textScaler: TextScaler.noScaling,
              style: context.type.titleLarge.copyWith(
                fontSize: size * _initialSizeRatio,
                fontWeight: FontWeight.w700,
                color: colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
