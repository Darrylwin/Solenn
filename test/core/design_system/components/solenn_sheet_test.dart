import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/components/solenn_sheet.dart';

import '../../../helpers/pump_screen.dart';

Widget _opener({bool isDismissible = true}) {
  return Builder(
    builder: (context) => Center(
      child: TextButton(
        onPressed: () => showSolennSheet<void>(
          context: context,
          isDismissible: isDismissible,
          builder: (_) => const SolennSheetScaffold(child: Text('Sheet body')),
        ),
        child: const Text('open'),
      ),
    ),
  );
}

// A point on the barrier, above any content-sized sheet.
const Offset _barrierPoint = Offset(195, 60);

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    group('showSolennSheet on $platform', () {
      testWidgets('should present the content', (tester) async {
        await pumpScreen(tester, _opener(), platform: platform);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('Sheet body'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should dismiss when the barrier is tapped', (tester) async {
        await pumpScreen(tester, _opener(), platform: platform);
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await tester.tapAt(_barrierPoint);
        await tester.pumpAndSettle();

        expect(find.text('Sheet body'), findsNothing);
      });

      testWidgets('should stay open when it is not dismissible', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _opener(isDismissible: false),
          platform: platform,
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await tester.tapAt(_barrierPoint);
        await tester.pumpAndSettle();

        expect(find.text('Sheet body'), findsOneWidget);
      });

      testWidgets('should not overflow on a small screen with large text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _opener(),
          platform: platform,
          size: const Size(320, 568),
          textScale: 2,
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });
  }

  group('SolennSheetScaffold', () {
    testWidgets('should draw a grabber on iOS only', (tester) async {
      await pumpScreen(tester, _opener(), platform: TargetPlatform.iOS);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(solennSheetGrabberKey), findsOneWidget);

      await tester.tapAt(_barrierPoint);
      await tester.pumpAndSettle();

      await pumpScreen(tester, _opener());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(solennSheetGrabberKey), findsNothing);
    });
  });
}
