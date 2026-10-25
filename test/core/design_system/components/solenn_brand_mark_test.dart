import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

ShapeBorder _shapeOf(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(SolennBrandMark),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as ShapeDecoration).shape;
}

void main() {
  testWidgets('should draw its initial at the requested size', (tester) async {
    await pumpScreen(
      tester,
      const Center(child: SolennBrandMark(initial: 'S', size: 56)),
    );

    expect(find.text('S'), findsOneWidget);
    expect(tester.getSize(find.byType(SolennBrandMark)), const Size(56, 56));
  });

  testWidgets('should be a circle by default', (tester) async {
    await pumpScreen(
      tester,
      const Center(child: SolennBrandMark(initial: 'S', size: 28)),
    );

    expect(_shapeOf(tester), isA<CircleBorder>());
  });

  testWidgets('should be a rounded square on request', (tester) async {
    await pumpScreen(
      tester,
      const Center(
        child: SolennBrandMark(
          initial: 'S',
          size: 56,
          shape: SolennBrandMarkShape.squircle,
        ),
      ),
    );

    expect(_shapeOf(tester), isA<RoundedRectangleBorder>());
  });

  testWidgets('should be hidden from screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(
      tester,
      const Center(child: SolennBrandMark(initial: 'S', size: 28)),
    );

    expect(find.bySemanticsLabel('S'), findsNothing);
    handle.dispose();
  });

  testWidgets('should ignore the system text scale', (tester) async {
    await pumpScreen(
      tester,
      const Center(child: SolennBrandMark(initial: 'S', size: 28)),
      textScale: 2,
    );

    expect(tester.getSize(find.byType(SolennBrandMark)), const Size(28, 28));
    expect(tester.takeException(), isNull);
  });
}
