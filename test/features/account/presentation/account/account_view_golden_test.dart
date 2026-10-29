@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/account/presentation/account/account_view.dart';

import '../../../../helpers/golden_helpers.dart';
import '../../../../helpers/load_app_fonts.dart';
import '../../../../helpers/pump_screen.dart';

AccountView _view({
  required String name,
  required String detail,
  String? badge,
}) => AccountView(
  planName: name,
  planDetail: detail,
  planBadge: badge,
  versionLabel: '0.1.0 (1)',
  onBackPressed: () {},
  onRestorePressed: () {},
  onTermsPressed: () {},
  onPrivacyPressed: () {},
  onLicensesPressed: () {},
);

AccountView _free() => _view(name: 'Solenn Free', detail: 'Standard accuracy');

AccountView _plus() => _view(
  name: 'Solenn Plus',
  detail: 'Annual · 7-day free trial',
  badge: 'PLUS',
);

void main() {
  setUpAll(loadAppFonts);

  for (final width in goldenWidths) {
    testWidgets('should match the golden of the free plan at $width', (
      tester,
    ) async {
      await pumpScreen(tester, _free(), size: Size(width, 900));

      await expectScreenGolden(goldenName('account-free', width));
    });
  }

  testWidgets('should match the golden of the Plus plan', (tester) async {
    await pumpScreen(tester, _plus(), size: const Size(390, 900));

    await expectScreenGolden(goldenName('account-plus', 390));
  });

  testWidgets('should match the golden of the Plus plan on iOS', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _plus(),
      platform: TargetPlatform.iOS,
      size: const Size(390, 900),
    );

    await expectScreenGolden(
      goldenName('account-plus', 390, platform: TargetPlatform.iOS),
    );
  });
}
