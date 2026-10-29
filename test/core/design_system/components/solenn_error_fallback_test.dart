import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

const String _title = 'Something went wrong';
const String _message = 'Please close Solenn and open it again.';

Widget _fallback({TextDirection textDirection = TextDirection.ltr}) =>
    SolennErrorFallback(
      initial: 'S',
      title: _title,
      message: _message,
      textDirection: textDirection,
    );

void main() {
  testWidgets('should draw its mark, title and message with no ancestor', (
    tester,
  ) async {
    await tester.pumpWidget(_fallback());

    expect(find.text('S'), findsOneWidget);
    expect(find.text(_title), findsOneWidget);
    expect(find.text(_message), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should be read as one sentence', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_fallback());

    expect(find.bySemanticsLabel('$_title. $_message'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('should follow the reading direction it is given', (
    tester,
  ) async {
    await tester.pumpWidget(_fallback(textDirection: TextDirection.rtl));

    expect(
      Directionality.of(tester.element(find.text(_title))),
      TextDirection.rtl,
    );
  });

  testWidgets('should paint the black background of the application', (
    tester,
  ) async {
    await tester.pumpWidget(_fallback());

    final box = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(SolennErrorFallback),
        matching: find.byType(ColoredBox),
      ),
    );

    expect(box.color, SolennColors.dark.background);
  });

  testWidgets('should scale down to fit a small slot', (tester) async {
    await tester.pumpWidget(
      Center(
        child: SizedBox(width: 76, height: 76, child: _fallback()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(SolennErrorFallback)),
      const Size(76, 76),
    );
  });

  testWidgets('should not overflow on a small screen', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_fallback());

    expect(tester.takeException(), isNull);
  });
}
