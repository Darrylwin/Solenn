import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/account/domain/legal/legal_document.dart';
import 'package:solenn/features/account/domain/legal/legal_document_parser.dart';
import 'package:solenn/features/account/presentation/legal/legal_view.dart';

import '../../../../helpers/pump_screen.dart';

final LegalDocument _document = const LegalDocumentParser().parse(
  List.generate(
    12,
    (index) => '# Section ${index + 1}\n\nParagraph of section ${index + 1}.',
  ).join('\n\n'),
);

Widget _view({VoidCallback? onBack}) => LegalView(
  title: 'Terms of Service',
  document: _document,
  onBackPressed: onBack ?? () {},
);

void main() {
  testWidgets('should show the title and the first section', (tester) async {
    await pumpScreen(tester, _view());

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Section 1'), findsOneWidget);
    expect(find.text('Paragraph of section 1.'), findsOneWidget);
  });

  testWidgets('should report the back button', (tester) async {
    var taps = 0;
    await pumpScreen(tester, _view(onBack: () => taps++));

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('should reach the last paragraph by scrolling', (tester) async {
    await pumpScreen(tester, _view());
    expect(find.text('Paragraph of section 12.'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -10000));
    await tester.pumpAndSettle();

    expect(find.text('Paragraph of section 12.'), findsOneWidget);
  });

  testWidgets('should keep the last line clear of the fade', (tester) async {
    await pumpScreen(tester, _view());
    await tester.drag(find.byType(ListView), const Offset(0, -10000));
    await tester.pumpAndSettle();

    final listBottom = tester.getBottomLeft(find.byType(ListView)).dy;
    final lastLine = tester
        .getBottomLeft(find.text('Paragraph of section 12.'))
        .dy;

    expect(listBottom - lastLine, greaterThanOrEqualTo(96));
  });

  testWidgets('should mark headings for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, _view());

    expect(
      tester.getSemantics(find.text('Section 1')),
      isSemantics(isHeader: true),
    );
    handle.dispose();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('should not overflow at x$scale on $platform', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _view(),
          platform: platform,
          size: const Size(320, 568),
          textScale: scale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  }
}
