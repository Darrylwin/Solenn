import 'package:flutter/foundation.dart';

/// Version information of the running build.
@immutable
class AppInfo {
  /// Creates the information from explicit values.
  const AppInfo({required this.version, required this.buildNumber});

  /// Semantic version, for example `0.1.0`.
  final String version;

  /// Monotonic build number injected by CI, for example `42`.
  final String buildNumber;
}
