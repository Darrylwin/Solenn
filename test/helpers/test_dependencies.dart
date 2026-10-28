import 'dart:math';

import 'package:solenn/app/app_dependencies.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/core/services/app_info.dart';
import 'package:solenn/core/services/app_logger.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';

import 'fake_clipboard_service.dart';
import 'fake_haptics_service.dart';

/// Builds a deterministic [AppDependencies] for tests.
AppDependencies buildTestDependencies({
  HapticsService? haptics,
  ClipboardService? clipboard,
}) {
  return AppDependencies(
    logger: const AppLogger(),
    haptics: haptics ?? FakeHapticsService(),
    clipboard: clipboard ?? FakeClipboardService(),
    appInfo: const AppInfo(version: '0.0.0', buildNumber: '0'),
    sabotageEngine: SabotageEngine(random: Random(42)),
  );
}
