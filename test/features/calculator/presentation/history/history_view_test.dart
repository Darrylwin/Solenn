import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/history/history_item.dart';
import 'package:solenn/features/calculator/presentation/history/history_view.dart';

import '../../../../helpers/pump_screen.dart';

const List<HistoryItem> _items = [
  HistoryItem(expression: '36×4', result: '414'),
  HistoryItem(expression: '9−3', result: '12'),
  HistoryItem(expression: '24,000+220', result: '24,820'),
];

Widget _view({
  List<HistoryItem> items = _items,
  VoidCallback? onClear,
}) {
  return Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: HistoryView(items: items, onClearPressed: onClear ?? () {}),
    ),
  );
}

/// Finds the span showing exactly [text], at any depth of [root].
TextSpan? _findSpan(InlineSpan root, String text) {
  TextSpan? found;
  root.visitChildren((span) {
    if (span is TextSpan && span.text == text) {
      found = span;
      return false;
    }
    return true;
  });
  return found;
}

void main() {
  group('HistoryView content', () {
    testWidgets('should list every result', (tester) async {
      await pumpScreen(tester, _view());

      expect(find.text('History'), findsOneWidget);
      expect(find.text('414'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('24,820'), findsOneWidget);
    });

    testWidgets('should keep the given order', (tester) async {
      await pumpScreen(tester, _view());

      final first = tester.getTopLeft(find.text('414')).dy;
      final last = tester.getTopLeft(find.text('24,820')).dy;

      expect(first, lessThan(last));
    });

    testWidgets('should separate entries with hairlines', (tester) async {
      await pumpScreen(tester, _view());

      expect(
        find.descendant(
          of: find.byType(HistoryView),
          matching: find.byType(ColoredBox),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('should draw operators in the accent color', (tester) async {
      await pumpScreen(tester, _view(items: [_items.first]));

      final rich = tester.widget<RichText>(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText() == '36×4',
        ),
      );

      expect(
        _findSpan(rich.text, '×')?.style?.color,
        SolennColors.dark.accent,
      );
      expect(_findSpan(rich.text, '36')?.style?.color, isNull);
    });

    testWidgets('should describe an entry as one sentence', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, _view());

      expect(find.bySemanticsLabel('36×4 equals 414'), findsOneWidget);
      handle.dispose();
    });
  });

  group('HistoryView clearing', () {
    testWidgets('should report Clear', (tester) async {
      var cleared = 0;
      await pumpScreen(tester, _view(onClear: () => cleared++));

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(cleared, 1);
    });

    testWidgets('should show an empty state and disable Clear', (tester) async {
      var cleared = 0;
      await pumpScreen(
        tester,
        _view(items: const [], onClear: () => cleared++),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('No calculations yet'), findsOneWidget);
      expect(cleared, 0);
    });
  });

  group('HistoryView in a sheet', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should clear from the sheet on $platform', (tester) async {
        var cleared = 0;
        await pumpScreen(
          tester,
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showSolennSheet<void>(
                  context: context,
                  builder: (_) => SolennSheetScaffold(
                    child: HistoryView(
                      items: _items,
                      onClearPressed: () => cleared++,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
          platform: platform,
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();

        expect(cleared, 1);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('HistoryView accessibility and layout', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should meet guidelines on $platform', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, _view(), platform: platform);

        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('should not overflow with large text and a long result', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _view(
          items: const [
            HistoryItem(
              expression: '123,456,789×987,654,321',
              result: '1.2193263e+17',
            ),
          ],
        ),
        size: const Size(320, 568),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
