/// Named destinations of the application.
///
/// Raw route strings never appear in widgets; they go through this type.
enum AppRoute {
  /// The calculator.
  home('/')
  ;

  const AppRoute(this.path);

  /// The route name registered with the navigator.
  final String path;

  /// Resolves [path] to a route, or `null` when it is unknown.
  static AppRoute? fromPath(String? path) {
    for (final route in values) {
      if (route.path == path) return route;
    }
    return null;
  }
}
