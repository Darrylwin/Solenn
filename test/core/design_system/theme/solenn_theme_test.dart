import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

void main() {
  group('buildSolennTheme', () {
    final theme = buildSolennTheme();

    test('should be a dark theme', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, SolennColors.dark.background);
    });

    test('should register every token extension', () {
      expect(theme.extension<SolennColors>(), isNotNull);
      expect(theme.extension<SolennTypography>(), isNotNull);
      expect(theme.extension<SolennSpacing>(), isNotNull);
      expect(theme.extension<SolennRadii>(), isNotNull);
      expect(theme.extension<SolennMotion>(), isNotNull);
    });

    test('should map the palette onto the Material color scheme', () {
      expect(theme.colorScheme.primary, SolennColors.dark.accent);
      expect(theme.colorScheme.onPrimary, SolennColors.dark.onAccent);
      expect(theme.colorScheme.surface, SolennColors.dark.surface);
    });

    test('should pick the page transition of each platform', () {
      final builders = theme.pageTransitionsTheme.builders;

      expect(
        builders[TargetPlatform.android],
        isA<PredictiveBackPageTransitionsBuilder>(),
      );
      expect(
        builders[TargetPlatform.iOS],
        isA<CupertinoPageTransitionsBuilder>(),
      );
    });
  });

  test('system overlay style should draw light icons on transparent bars', () {
    expect(
      solennSystemUiOverlayStyle.statusBarIconBrightness,
      Brightness.light,
    );
    expect(solennSystemUiOverlayStyle.statusBarColor, Colors.transparent);
  });

  testWidgets('context should resolve every token from the theme', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSolennTheme(),
        home: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(captured.colors, same(SolennColors.dark));
    expect(captured.type, same(SolennTypography.standard));
    expect(captured.spacing, same(SolennSpacing.standard));
    expect(captured.radii, same(SolennRadii.standard));
    expect(captured.motion, same(SolennMotion.defaults));
  });
}
