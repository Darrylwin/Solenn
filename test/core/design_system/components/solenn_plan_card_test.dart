import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/components/solenn_chip.dart';
import 'package:solenn/core/design_system/components/solenn_plan_card.dart';

import '../../../helpers/pump_screen.dart';

const String _semantics = 'Annual plan';

Widget _card({
  bool selected = false,
  bool dense = false,
  VoidCallback? onPressed,
  VoidCallback? onPressStart,
  String? badge,
  String? subtitle,
  String? anchorPrice,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SolennPlanCard(
        title: 'Annual',
        price: r'$39.99',
        subtitle: subtitle,
        anchorPrice: anchorPrice,
        badge: badge,
        selected: selected,
        dense: dense,
        semanticLabel: _semantics,
        onPressed: onPressed,
        onPressStart: onPressStart,
      ),
    ),
  );
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    group('SolennPlanCard on $platform', () {
      testWidgets('should report the press start before the press', (
        tester,
      ) async {
        final events = <String>[];
        await pumpScreen(
          tester,
          _card(
            onPressStart: () => events.add('start'),
            onPressed: () => events.add('pressed'),
          ),
          platform: platform,
        );

        await tester.tap(find.text('Annual'));
        await tester.pumpAndSettle();

        expect(events, ['start', 'pressed']);
      });

      testWidgets('should meet tap target guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, _card(onPressed: () {}), platform: platform);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });
    });
  }

  group('SolennPlanCard content', () {
    testWidgets('should show every provided line', (tester) async {
      await pumpScreen(
        tester,
        _card(
          subtitle: '7-day free trial',
          anchorPrice: r'$59.88',
          badge: 'BEST VALUE',
          onPressed: () {},
        ),
      );

      expect(find.text('Annual'), findsOneWidget);
      expect(find.text(r'$39.99'), findsOneWidget);
      expect(find.text('7-day free trial'), findsOneWidget);
      expect(find.text(r'$59.88'), findsOneWidget);
      expect(find.text('BEST VALUE'), findsOneWidget);
    });

    testWidgets('should strike through the anchor price', (tester) async {
      await pumpScreen(
        tester,
        _card(anchorPrice: r'$59.88', onPressed: () {}),
      );

      expect(
        tester.widget<Text>(find.text(r'$59.88')).style!.decoration,
        TextDecoration.lineThrough,
      );
    });

    testWidgets('should omit optional lines when not provided', (tester) async {
      await pumpScreen(tester, _card(onPressed: () {}));

      expect(find.byType(SolennChip), findsNothing);
      expect(find.text(r'$59.88'), findsNothing);
    });

    testWidgets('should be shorter in its dense variant', (tester) async {
      await pumpScreen(tester, _card(subtitle: 'Billed monthly'));
      final regular = tester.getSize(find.byType(SolennPlanCard)).height;

      await pumpScreen(tester, _card(subtitle: 'Billed monthly', dense: true));
      final dense = tester.getSize(find.byType(SolennPlanCard)).height;

      expect(dense, lessThan(regular));
    });

    testWidgets('should not overflow with large text on a small screen', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        SingleChildScrollView(
          child: _card(
            subtitle: r'7-day free trial · $3.33 / month',
            anchorPrice: r'$59.88',
            badge: 'BEST VALUE · SAVE 33%',
            onPressed: () {},
          ),
        ),
        textScale: 2,
        size: const Size(320, 568),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('should keep the price beside the title at normal size', (
      tester,
    ) async {
      await pumpScreen(tester, _card(onPressed: () {}));

      final title = tester.getRect(find.text('Annual'));
      final price = tester.getRect(find.text(r'$39.99'));

      expect(price.left, greaterThanOrEqualTo(title.right));
    });

    testWidgets('should stack the price under the title with large text', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        SingleChildScrollView(child: _card(onPressed: () {})),
        textScale: 2,
      );

      final title = tester.getRect(find.text('Annual'));
      final price = tester.getRect(find.text(r'$39.99'));

      expect(price.top, greaterThanOrEqualTo(title.bottom));
    });
  });

  group('SolennPlanCard semantics', () {
    testWidgets('should be a checked radio when selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, _card(selected: true, onPressed: () {}));

      expect(
        tester.getSemantics(find.bySemanticsLabel(_semantics)),
        isSemantics(
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('should be an unchecked radio when not selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, _card(onPressed: () {}));

      expect(
        tester.getSemantics(find.bySemanticsLabel(_semantics)),
        isSemantics(
          hasCheckedState: true,
          isChecked: false,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      handle.dispose();
    });
  });
}
