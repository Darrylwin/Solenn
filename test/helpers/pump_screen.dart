import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/l10n/l10n.dart';

import 'fake_clipboard_service.dart';
import 'fake_haptics_service.dart';

/// Pumps [child] inside the Solenn theme, localizations and fake platform
/// services, at a given screen [size], text scale and platform dialect.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  TargetPlatform platform = TargetPlatform.android,
  Size size = const Size(390, 844),
  double textScale = 1,
  HapticsService? haptics,
  ClipboardService? clipboard,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HapticsService>.value(
          value: haptics ?? FakeHapticsService(),
        ),
        RepositoryProvider<ClipboardService>.value(
          value: clipboard ?? FakeClipboardService(),
        ),
      ],
      child: MaterialApp(
        theme: buildSolennTheme().copyWith(platform: platform),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: app!,
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
}
