@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/golden_helpers.dart';
import '../../../helpers/load_app_fonts.dart';
import '../../../helpers/pump_screen.dart';

const double _keySize = 76;
const Size _tall = Size(390, 1400);

Widget _key(
  SolennKeyVariant variant, {
  String? label,
  IconData? icon,
  bool selected = false,
  bool enabled = true,
}) {
  return SizedBox.square(
    dimension: _keySize,
    child: SolennKey(
      variant: variant,
      label: label,
      icon: icon,
      semanticLabel: label ?? 'key',
      selected: selected,
      onPressed: enabled ? () {} : null,
    ),
  );
}

Widget _keys() => goldenGallery(
  Padding(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _key(SolennKeyVariant.digit, label: '7'),
        _key(SolennKeyVariant.auxiliary, label: '+/\u2212'),
        _key(SolennKeyVariant.function, label: 'AC'),
        _key(SolennKeyVariant.function, icon: Icons.backspace_outlined),
        _key(SolennKeyVariant.accent, label: '+'),
        _key(SolennKeyVariant.accent, label: '+', selected: true),
        _key(SolennKeyVariant.accent, label: '='),
        _key(SolennKeyVariant.digit, label: '7', enabled: false),
      ],
    ),
  ),
);

Widget _plans(double width) => goldenGallery(
  width: width,
  Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SolennPlanCard(
          title: 'Annual',
          subtitle: r'7-day free trial · $3.33 / month',
          price: r'$39.99',
          anchorPrice: r'$59.88',
          badge: 'BEST VALUE · SAVE 33%',
          selected: true,
          semanticLabel: 'Annual plan',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        SolennPlanCard(
          title: 'Monthly',
          subtitle: 'Billed monthly · Cancel anytime',
          price: r'$4.99',
          selected: false,
          semanticLabel: 'Monthly plan',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        SolennPlanCard(
          title: 'Enterprise',
          subtitle: 'Slightly less wrong results',
          price: r'$149.99',
          dense: true,
          selected: false,
          semanticLabel: 'Enterprise plan',
          onPressed: () {},
        ),
      ],
    ),
  ),
);

Widget _surfaces(double width) => goldenGallery(
  width: width,
  Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: SolennChip(label: 'PLUS'),
        ),
        const SizedBox(height: 16),
        const SolennBanner(
          title: 'Welcome to Solenn Plus',
          message: 'Your plan is active. Calculate without limits.',
        ),
        const SizedBox(height: 16),
        SolennListGroup(
          children: [
            SolennListTile(title: 'Terms of Service', onPressed: () {}),
            const SolennListTile(title: 'Version', value: '0.1.0 (1)'),
          ],
        ),
        const SizedBox(height: 16),
        SolennPrimaryButton(label: 'Start 7-day free trial', onPressed: () {}),
        const SizedBox(height: 8),
        Center(
          child: SolennTextButton(
            label: 'I prefer inaccurate results',
            onPressed: () {},
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (final label in ['Restore', 'Terms', 'Privacy'])
              SolennTextButton(
                label: label,
                size: SolennTextButtonSize.small,
                onPressed: () {},
              ),
          ],
        ),
      ],
    ),
  ),
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets('should match the golden of the keys', (tester) async {
    await pumpScreen(tester, _keys(), size: _tall);

    await expectBoundaryGolden('keys-390');
  });

  group('a pressed key on iOS', () {
    final _ =
        {
          'digit': _key(SolennKeyVariant.digit, label: '7'),
          'accent': _key(SolennKeyVariant.accent, label: '+'),
        }..forEach((name, key) {
          testWidgets('should match the golden of the $name key', (
            tester,
          ) async {
            await pumpScreen(
              tester,
              goldenGallery(
                Padding(padding: const EdgeInsets.all(12), child: key),
              ),
              platform: TargetPlatform.iOS,
              size: _tall,
            );
            final gesture = await tester.startGesture(
              tester.getCenter(find.byType(SolennKey)),
            );
            await tester.pump(SolennMotion.defaults.press);

            await expectBoundaryGolden('key-$name-pressed-ios');

            await gesture.up();
            await tester.pumpAndSettle();
          });
        });
  });

  for (final width in goldenWidths) {
    testWidgets('should match the golden of the plan cards at $width', (
      tester,
    ) async {
      await pumpScreen(tester, _plans(width), size: Size(width, 1400));

      await expectBoundaryGolden(goldenName('plan-cards', width));
    });

    testWidgets('should match the golden of the surfaces at $width', (
      tester,
    ) async {
      await pumpScreen(tester, _surfaces(width), size: Size(width, 1400));

      await expectBoundaryGolden(goldenName('surfaces', width));
    });
  }
}
