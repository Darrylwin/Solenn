import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors_derived.dart';

void main() {
  group('SolennColors', () {
    const colors = SolennColors.dark;
    const override = Color(0xFFFF0000);

    test('should keep every value when copied without overrides', () {
      expect(colors.copyWith().accent, colors.accent);
    });

    test('should replace only the given value when copied', () {
      final copy = colors.copyWith(accent: override);

      expect(copy.accent, override);
      expect(copy.background, colors.background);
    });

    test('should interpolate towards another palette', () {
      final other = colors.copyWith(accent: override);

      expect(colors.lerp(other, 0).accent, colors.accent);
      expect(colors.lerp(other, 1).accent, override);
    });

    test('should stay unchanged when interpolating with a foreign type', () {
      expect(colors.lerp(null, 0.5), same(colors));
    });

    test('should derive the sheet handle from the muted icon color', () {
      expect(colors.sheetHandle.a, closeTo(0.5, 0.01));
      expect(colors.sheetHandle.r, colors.iconMuted.r);
    });
  });

  group('SolennTypography', () {
    const type = SolennTypography.standard;

    test('should replace only the given style when copied', () {
      const style = TextStyle(fontSize: 10);

      final copy = type.copyWith(displayResult: style);

      expect(copy.displayResult, same(style));
      expect(copy.body, same(type.body));
    });

    test('should interpolate towards another scale', () {
      final other = type.copyWith(displayResult: const TextStyle(fontSize: 10));

      expect(type.lerp(other, 0).displayResult.fontSize, 64);
      expect(type.lerp(other, 1).displayResult.fontSize, 10);
    });

    test('should stay unchanged when interpolating with a foreign type', () {
      expect(type.lerp(null, 0.5), same(type));
    });
  });

  group('SolennSpacing', () {
    const spacing = SolennSpacing.standard;

    test('should replace only the given value when copied', () {
      final copy = spacing.copyWith(md: 99);

      expect(copy.md, 99);
      expect(copy.lg, spacing.lg);
    });

    test('should switch to the target past the midpoint', () {
      final other = spacing.copyWith(md: 99);

      expect(spacing.lerp(other, 0.25).md, spacing.md);
      expect(spacing.lerp(other, 0.75).md, 99);
      expect(spacing.lerp(null, 0.75), same(spacing));
    });
  });

  group('SolennRadii', () {
    const radii = SolennRadii.standard;

    test('should replace only the given value when copied', () {
      final copy = radii.copyWith(chip: 1);

      expect(copy.chip, 1);
      expect(copy.sheet, radii.sheet);
    });

    test('should switch to the target past the midpoint', () {
      final other = radii.copyWith(chip: 1);

      expect(radii.lerp(other, 0.25).chip, radii.chip);
      expect(radii.lerp(other, 0.75).chip, 1);
      expect(radii.lerp(null, 0.75), same(radii));
    });
  });

  group('SolennMotion', () {
    const motion = SolennMotion.defaults;

    test('should replace only the given value when copied', () {
      final copy = motion.copyWith(press: Duration.zero);

      expect(copy.press, Duration.zero);
      expect(copy.fast, motion.fast);
    });

    test('should switch to the target past the midpoint', () {
      final other = motion.copyWith(press: Duration.zero);

      expect(motion.lerp(other, 0.25).press, motion.press);
      expect(motion.lerp(other, 0.75).press, Duration.zero);
      expect(motion.lerp(null, 0.75), same(motion));
    });
  });
}
