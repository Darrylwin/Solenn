import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

void main() {
  testWidgets('should show its label on the accent color', (tester) async {
    await pumpScreen(tester, const Center(child: SolennChip(label: 'PLUS')));

    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(SolennChip),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    final text = tester.widget<Text>(find.text('PLUS'));

    expect(decoration.color, SolennColors.dark.accent);
    expect(text.style!.color, SolennColors.dark.onAccent);
  });
}
