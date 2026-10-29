@Tags(<String>['golden'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/history/history_item.dart';
import 'package:solenn/features/calculator/presentation/history/history_view.dart';

import '../../../../helpers/golden_helpers.dart';
import '../../../../helpers/load_app_fonts.dart';
import '../../../../helpers/pump_screen.dart';

const List<HistoryItem> _items = [
  HistoryItem(expression: '36\u00D74', result: '414'),
  HistoryItem(expression: '9\u22123', result: '12'),
  HistoryItem(expression: '7.3+1.2', result: '10'),
  HistoryItem(expression: '24,000+220', result: '24,820'),
];

Future<void> _openSheet(
  WidgetTester tester, {
  required List<HistoryItem> items,
  required Size size,
  required TargetPlatform platform,
}) async {
  late BuildContext context;
  await pumpScreen(
    tester,
    Builder(
      builder: (inner) {
        context = inner;
        return const SizedBox.expand();
      },
    ),
    platform: platform,
    size: size,
  );

  unawaited(
    showSolennSheet<void>(
      context: context,
      builder: (_) => SolennSheetScaffold(
        child: HistoryView(items: items, onClearPressed: () {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final width in goldenWidths) {
    testWidgets('should match the golden of the history at $width', (
      tester,
    ) async {
      await _openSheet(
        tester,
        items: _items,
        size: phoneSize(width),
        platform: TargetPlatform.android,
      );

      await expectScreenGolden(
        goldenName('history', width, platform: TargetPlatform.android),
      );
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('should match the golden of the empty history on $platform', (
      tester,
    ) async {
      await _openSheet(
        tester,
        items: const [],
        size: phoneSize(390),
        platform: platform,
      );

      await expectScreenGolden(
        goldenName('history-empty', 390, platform: platform),
      );
    });
  }

  testWidgets('should match the golden of the history on iOS', (tester) async {
    await _openSheet(
      tester,
      items: _items,
      size: phoneSize(390),
      platform: TargetPlatform.iOS,
    );

    await expectScreenGolden(
      goldenName('history', 390, platform: TargetPlatform.iOS),
    );
  });
}
