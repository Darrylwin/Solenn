import 'package:flutter/material.dart';

/// Platform detection for adaptive components.
///
/// It reads the theme platform instead of `dart:io`, so tests and previews
/// can switch dialect (see section 12 of the specification).
extension PlatformStyleContext on BuildContext {
  /// Whether iOS-style interaction (no ripple, brightening fill) applies.
  bool get usesCupertinoStyle => switch (Theme.of(this).platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => true,
    _ => false,
  };
}
