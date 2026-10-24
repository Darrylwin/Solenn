import 'dart:async';

import 'package:flutter/services.dart';
import 'package:solenn/core/platform/haptics_service.dart';

/// [HapticsService] backed by the platform haptic engine.
///
/// The framework maps each call to the native constant of the host OS and
/// honors the user's system haptic settings.
class SystemHapticsService implements HapticsService {
  /// Creates the service.
  const SystemHapticsService();

  @override
  void selection() => unawaited(HapticFeedback.selectionClick());

  @override
  void light() => unawaited(HapticFeedback.lightImpact());

  @override
  void medium() => unawaited(HapticFeedback.mediumImpact());
}
