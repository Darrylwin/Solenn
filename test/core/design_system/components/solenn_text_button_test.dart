import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

Widget _button({
  VoidCallback? onPressed,
  SolennTextButtonSize size = SolennTextButtonSize.regular,
}) {
  return Center(
    child: SolennTextButton(
      label: 'Restore',
      onPressed: onPressed,
      size: size,
    ),
  );
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    group('SolennTextButton on $platform', () {
      testWidgets('should call onPressed when tapped', (tester) async {
        var taps = 0;
        await pumpScreen(
          tester,
          _button(onPressed: () => taps++),
          platform: platform,
        );

        await tester.tap(find.text('Restore'));
        await tester.pumpAndSettle();

        expect(taps, 1);
      });

      testWidgets('should keep a touch target of at least 44 pixels', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(
          tester,
          _button(onPressed: () {}, size: SolennTextButtonSize.small),
          platform: platform,
        );

        final size = tester.getSize(find.byType(SolennTextButton));

        expect(size.height, greaterThanOrEqualTo(44));
        expect(size.width, greaterThanOrEqualTo(44));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    });
  }

  testWidgets('should use a smaller label for the small size', (tester) async {
    await pumpScreen(tester, _button(onPressed: () {}));
    final regular = tester.widget<Text>(find.text('Restore')).style!.fontSize!;

    await pumpScreen(
      tester,
      _button(onPressed: () {}, size: SolennTextButtonSize.small),
    );
    final small = tester.widget<Text>(find.text('Restore')).style!.fontSize!;

    expect(small, lessThan(regular));
  });

  testWidgets('should use the secondary text color', (tester) async {
    await pumpScreen(tester, _button(onPressed: () {}));

    expect(
      tester.widget<Text>(find.text('Restore')).style!.color,
      SolennColors.dark.textSecondary,
    );
  });

  testWidgets('should render when disabled', (tester) async {
    await pumpScreen(tester, _button());

    expect(find.text('Restore'), findsOneWidget);
  });
}
