import 'dart:math';

import 'package:solenn/app/app_dependencies.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/core/services/app_info.dart';
import 'package:solenn/core/services/app_logger.dart';

import 'fake_haptics_service.dart';

/// Builds a deterministic [AppDependencies] for tests.
AppDependencies buildTestDependencies({HapticsService? haptics}) {
  return AppDependencies(
    logger: const AppLogger(),
    haptics: haptics ?? FakeHapticsService(),
    appInfo: const AppInfo(version: '0.0.0', buildNumber: '0'),
    random: Random(42),
  );
}
