import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

const Key _contentKey = Key('content');

Widget _page({VoidCallback? onBack, String title = 'Account'}) {
  return SolennPageScaffold(
    title: title,
    backSemanticLabel: 'Back',
    onBackPressed: onBack ?? () {},
    child: const SizedBox.expand(key: _contentKey),
  );
}

void main() {
  testWidgets('should show the title and the content', (tester) async {
    await pumpScreen(tester, _page());

    expect(find.text('Account'), findsOneWidget);
    expect(find.byKey(_contentKey), findsOneWidget);
  });

  testWidgets('should report the back button', (tester) async {
    var taps = 0;
    await pumpScreen(tester, _page(onBack: () => taps++));

    await tester.tap(find.byType(SolennBackButton));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('should mark the title as a header', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, _page());

    expect(
      tester.getSemantics(find.text('Account')),
      isSemantics(isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('should keep the content within the margins', (tester) async {
    await pumpScreen(tester, _page());

    expect(tester.getSize(find.byKey(_contentKey)).width, 390 - 48);
  });

  testWidgets('should cap the content width on wide screens', (tester) async {
    await pumpScreen(tester, _page(), size: const Size(1024, 800));

    expect(tester.getSize(find.byKey(_contentKey)).width, 430);
  });

  testWidgets('should wrap a long title instead of overflowing', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _page(title: 'Terms of Service and everything else'),
      size: const Size(320, 568),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
