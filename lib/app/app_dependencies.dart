import 'package:flutter/foundation.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/core/services/app_info.dart';
import 'package:solenn/core/services/app_logger.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';

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
    required this.sabotageEngine,
  });

  /// Logging facade.
  final AppLogger logger;

  /// Haptic feedback.
  final HapticsService haptics;

  /// Version information of the running build.
  final AppInfo appInfo;

  /// The engine that decides every lie of the launch.
  ///
  /// It is stateful (it remembers each expression's lie), so exactly one
  /// instance exists per launch, seeded once.
  final SabotageEngine sabotageEngine;
}
