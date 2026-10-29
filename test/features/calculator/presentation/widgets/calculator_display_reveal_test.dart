import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_display.dart';

import '../../../../helpers/pump_screen.dart';

class _Harness {
  final ValueNotifier<Object?> key = ValueNotifier<Object?>(null);

  Widget build() => Center(
    child: SizedBox(
      width: 342,
      height: 196,
      child: ValueListenableBuilder<Object?>(
        valueListenable: key,
        builder: (_, value, _) => CalculatorDisplay(
          expression: '24,000 + 220',
          result: '24,820',
          revealKey: value,
        ),
      ),
    ),
  );
}

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(SolennReveal),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

void main() {
  testWidgets('should show the result at once without a reveal key', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.key.dispose);

    await pumpScreen(tester, harness.build());

    expect(find.text('24,820'), findsOneWidget);
    expect(_opacity(tester), 1);
  });

  testWidgets('should reveal the result when the key changes', (tester) async {
    final harness = _Harness();
    addTearDown(harness.key.dispose);
    await pumpScreen(tester, harness.build());

    harness.key.value = 1;
    await tester.pump();
    expect(_opacity(tester), 0);

    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
    expect(find.text('24,820'), findsOneWidget);
  });
}
