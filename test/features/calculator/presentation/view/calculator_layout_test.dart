import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_layout.dart';

void main() {
  const spacing = SolennSpacing.standard;

  double diameter({
    required double width,
    required double height,
    bool hasBanner = false,
  }) => calculatorKeyDiameter(
    spacing: spacing,
    width: width,
    height: height,
    hasBanner: hasBanner,
  );

  group('calculatorKeyDiameter', () {
    test('should be limited by the width on tall screens', () {
      expect(diameter(width: 342, height: 2000), closeTo(76.5, 0.001));
    });

    test('should be limited by the height on short screens', () {
      expect(
        diameter(width: 342, height: 640),
        lessThan(diameter(width: 342, height: 2000)),
      );
    });

    test('should shrink when a banner is shown', () {
      expect(
        diameter(width: 342, height: 700, hasBanner: true),
        lessThan(diameter(width: 342, height: 700)),
      );
    });

    test('should never go below the minimum touch target', () {
      expect(
        diameter(width: 342, height: 100),
        spacing.minTouchTarget,
      );
    });
  });

  group('calculatorBannerFits', () {
    test('should fit on a tall screen', () {
      expect(calculatorBannerFits(spacing: spacing, height: 2000), isTrue);
    });

    test('should not fit on a very short screen', () {
      expect(calculatorBannerFits(spacing: spacing, height: 100), isFalse);
    });

    test('should only fit when the keys keep the touch target', () {
      for (var height = 300.0; height <= 1200; height += 10) {
        final fits = calculatorBannerFits(spacing: spacing, height: height);
        final keys = diameter(width: 1000, height: height, hasBanner: true);

        expect(
          fits,
          keys > spacing.minTouchTarget ||
              keys == spacing.minTouchTarget &&
                  calculatorBannerFits(spacing: spacing, height: height),
          reason: 'height $height',
        );
        if (fits) {
          expect(keys, greaterThanOrEqualTo(spacing.minTouchTarget));
        }
      }
    });
  });
}
