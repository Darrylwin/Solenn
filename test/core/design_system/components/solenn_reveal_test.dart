import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

const Duration _start = Duration(milliseconds: 1);

class _Harness {
  final ValueNotifier<Object?> key = ValueNotifier<Object?>(1);

  Widget build() => Center(
    child: ValueListenableBuilder<Object?>(
      valueListenable: key,
      builder: (_, value, _) =>
          SolennReveal(revealKey: value, child: const Text('result')),
    ),
  );
}

Widget _reduced(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child,
  ),
);

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(SolennReveal),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

double _rise(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(SolennReveal),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .getTranslation()
    .y;

void main() {
  testWidgets('should show its child at once when first built', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.key.dispose);

    await pumpScreen(tester, harness.build());

    expect(find.text('result'), findsOneWidget);
    expect(_opacity(tester), 1);
    expect(_rise(tester), 0);
  });

  testWidgets('should fade and rise when the key changes', (tester) async {
    final harness = _Harness();
    addTearDown(harness.key.dispose);
    await pumpScreen(tester, harness.build());

    harness.key.value = 2;
    await tester.pump();
    expect(_opacity(tester), 0);
    expect(_rise(tester), 8);

    await tester.pump(_start);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_opacity(tester), inExclusiveRange(0, 1));
    expect(_rise(tester), inExclusiveRange(0, 8));

    await tester.pump(const Duration(milliseconds: 101));
    expect(_opacity(tester), 1);
    expect(_rise(tester), 0);
  });

  testWidgets('should not restart when rebuilt with the same key', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.key.dispose);
    await pumpScreen(tester, harness.build());
    harness.key.value = 2;
    await tester.pump();
    await tester.pumpAndSettle();

    harness.key.value = 2;
    await tester.pump();

    expect(_opacity(tester), 1);
  });

  testWidgets('should show the child at once when the key becomes null', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.key.dispose);
    await pumpScreen(tester, harness.build());
    harness.key.value = 2;
    await tester.pump();
    expect(_opacity(tester), 0);

    harness.key.value = null;
    await tester.pump();

    expect(_opacity(tester), 1);
    expect(_rise(tester), 0);
  });

  testWidgets('should reveal again for each new key', (tester) async {
    final harness = _Harness();
    addTearDown(harness.key.dispose);
    await pumpScreen(tester, harness.build());
    harness.key.value = 2;
    await tester.pumpAndSettle();

    harness.key.value = 3;
    await tester.pump();

    expect(_opacity(tester), 0);
  });

  group('when the user asked for less motion', () {
    testWidgets('should only fade, without any rise', (tester) async {
      final harness = _Harness();
      addTearDown(harness.key.dispose);
      await pumpScreen(tester, _reduced(harness.build()));

      harness.key.value = 2;
      await tester.pump();
      expect(_opacity(tester), 0);
      expect(_rise(tester), 0);

      await tester.pump(_start);
      await tester.pump(const Duration(milliseconds: 60));
      expect(_opacity(tester), inExclusiveRange(0, 1));
      expect(_rise(tester), 0);
    });

    testWidgets('should be over within 120 milliseconds', (tester) async {
      final harness = _Harness();
      addTearDown(harness.key.dispose);
      await pumpScreen(tester, _reduced(harness.build()));

      harness.key.value = 2;
      await tester.pump();
      await tester.pump(_start);
      await tester.pump(const Duration(milliseconds: 121));

      expect(_opacity(tester), 1);
    });
  });
}
