@Tags(<String>['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/account/domain/legal/legal_document_parser.dart';
import 'package:solenn/features/account/presentation/legal/legal_view.dart';

import '../../../../helpers/golden_helpers.dart';
import '../../../../helpers/load_app_fonts.dart';
import '../../../../helpers/pump_screen.dart';

const String _source = '''
# Acceptance

By using Solenn you accept these terms. If you do not accept them, please stop using the application. Solenn is a calculator, and nothing it shows should be relied on.

# Use

Solenn is provided as it is. Its results are deliberately wrong, and its subscription offer never charges anything: no payment is ever taken.

# Data

Solenn collects nothing and sends nothing. It has no network access, no account and no storage that outlives the application.

# Changes

These terms can change with a new release of the application.
''';

void main() {
  setUpAll(loadAppFonts);

  for (final width in goldenWidths) {
    testWidgets('should match the golden of a legal page at $width', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        LegalView(
          title: 'Terms of Service',
          document: const LegalDocumentParser().parse(_source),
          onBackPressed: () {},
        ),
        size: phoneSize(width),
      );

      await expectScreenGolden(goldenName('legal', width));
    });
  }
}
