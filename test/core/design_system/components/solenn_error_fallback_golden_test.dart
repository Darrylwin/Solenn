@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/golden_helpers.dart';
import '../../../helpers/load_app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('should match the golden of the error fallback', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const RepaintBoundary(
        key: goldenBoundaryKey,
        child: SolennErrorFallback(
          initial: 'S',
          title: 'Something went wrong',
          message: 'Please close Solenn and open it again.',
        ),
      ),
    );

    await expectBoundaryGolden('error-fallback-390');
  });
}
