import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/router/app_route.dart';
import 'package:solenn/app/router/app_router.dart';

void main() {
  group('AppRoute.fromPath', () {
    test('should resolve a known path', () {
      expect(AppRoute.fromPath('/'), AppRoute.home);
    });

    test('should return null for an unknown or missing path', () {
      expect(AppRoute.fromPath('/unknown'), isNull);
      expect(AppRoute.fromPath(null), isNull);
    });
  });

  group('onGenerateAppRoute', () {
    test('should build the home route', () {
      final route = onGenerateAppRoute(const RouteSettings(name: '/'));

      expect(route, isNotNull);
      expect(route!.settings.name, '/');
    });

    test('should reject an unknown route', () {
      expect(onGenerateAppRoute(const RouteSettings(name: '/x')), isNull);
    });
  });
}
