import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/components/solenn_primary_button.dart';

import '../../../helpers/pump_screen.dart';

const String _label = 'Start 7-day free trial';

Widget _button({
  VoidCallback? onPressed,
  VoidCallback? onPressStart,
  bool loading = false,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: SolennPrimaryButton(
        label: _label,
        onPressed: onPressed,
        onPressStart: onPressStart,
        loading: loading,
      ),
    ),
  );
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    group('SolennPrimaryButton on $platform', () {
      testWidgets('should report the press start before the press', (
        tester,
      ) async {
        final events = <String>[];
        await pumpScreen(
          tester,
          _button(
            onPressStart: () => events.add('start'),
            onPressed: () => events.add('pressed'),
          ),
          platform: platform,
        );

        await tester.tap(find.text(_label));
        await tester.pumpAndSettle();

        expect(events, ['start', 'pressed']);
      });

      testWidgets('should be 60 logical pixels tall and span the width', (
        tester,
      ) async {
        await pumpScreen(tester, _button(onPressed: () {}), platform: platform);

        final size = tester.getSize(find.byType(SolennPrimaryButton));

        expect(size.height, solennButtonHeight);
        expect(size.width, 390 - 48);
      });

      testWidgets('should ignore taps when disabled', (tester) async {
        var started = false;
        await pumpScreen(
          tester,
          _button(onPressStart: () => started = true),
          platform: platform,
        );

        await tester.tap(find.text(_label));
        await tester.pumpAndSettle();

        expect(started, isFalse);
      });

      testWidgets('should ignore taps while loading', (tester) async {
        var taps = 0;
        await pumpScreen(
          tester,
          _button(onPressed: () => taps++, loading: true),
          platform: platform,
        );

        await tester.tap(find.byType(SolennPrimaryButton));
        await tester.pump();

        expect(taps, 0);
      });

      testWidgets('should expose its label and meet guidelines', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, _button(onPressed: () {}), platform: platform);

        expect(find.bySemanticsLabel(_label), findsOneWidget);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    });
  }

  testWidgets('should show a Material spinner while loading on Android', (
    tester,
  ) async {
    await pumpScreen(tester, _button(onPressed: () {}, loading: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('should show a Cupertino spinner while loading on iOS', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _button(onPressed: () {}, loading: true),
      platform: TargetPlatform.iOS,
    );

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should not show a spinner when idle', (tester) async {
    await pumpScreen(tester, _button(onPressed: () {}));

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
