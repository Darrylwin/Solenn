import 'dart:developer' as developer;

/// Thin logging facade over `dart:developer`.
///
/// It is stateless on purpose: there is no logger registry to configure or
/// reset between tests.
class AppLogger {
  /// Creates a logger.
  const AppLogger();

  static const String _name = 'solenn';
  static const int _infoLevel = 800;
  static const int _warningLevel = 900;
  static const int _errorLevel = 1000;

  /// Logs an informational message.
  void info(String message) {
    developer.log(message, name: _name, level: _infoLevel);
  }

  /// Logs a recoverable problem.
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: _warningLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs a failure.
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: _errorLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
