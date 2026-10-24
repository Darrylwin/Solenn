import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/core/services/app_info.dart';
import 'package:solenn/core/services/app_logger.dart';

/// Everything the application needs from the outside world, assembled once
/// by `bootstrap` and injected by constructor.
///
/// Tests build their own instance with fakes; there is no global state.
@immutable
class AppDependencies {
  /// Creates the dependency set.
  const AppDependencies({
    required this.logger,
    required this.haptics,
    required this.appInfo,
    required this.random,
  });

  /// Logging facade.
  final AppLogger logger;

  /// Haptic feedback.
  final HapticsService haptics;

  /// Version information of the running build.
  final AppInfo appInfo;

  /// Randomness source, seeded once per launch.
  final Random random;
}
