import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/components/solenn_banner.dart';

import '../../../helpers/pump_screen.dart';

void main() {
  const banner = Center(
    child: SolennBanner(
      title: 'Welcome to Solenn Plus',
      message: 'Your plan is active.',
    ),
  );

  testWidgets('should show the title, the message and a check mark', (
    tester,
  ) async {
    await pumpScreen(tester, banner);

    expect(find.text('Welcome to Solenn Plus'), findsOneWidget);
    expect(find.text('Your plan is active.'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('should be announced as one live region', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, banner);

    final node = tester.getSemantics(
      find.bySemanticsLabel('Welcome to Solenn Plus. Your plan is active.'),
    );

    expect(node, isSemantics(isLiveRegion: true));
    handle.dispose();
  });

  testWidgets('should not overflow with large text', (tester) async {
    await pumpScreen(tester, banner, textScale: 2, size: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });
}
