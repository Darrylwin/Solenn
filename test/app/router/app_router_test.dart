import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/router/app_route.dart';
import 'package:solenn/app/router/app_router.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';
import 'package:solenn/l10n/l10n.dart';

import '../../helpers/fake_asset_bundle.dart';

void main() {
  group('AppRoute.fromPath', () {
    test('should resolve every known path', () {
      expect(AppRoute.fromPath('/'), AppRoute.home);
      expect(AppRoute.fromPath('/account'), AppRoute.account);
      expect(AppRoute.fromPath('/account/legal'), AppRoute.accountLegal);
    });

    test('should return null for an unknown or missing path', () {
      expect(AppRoute.fromPath('/unknown'), isNull);
      expect(AppRoute.fromPath(null), isNull);
    });

    test('should give every route its own path', () {
      final paths = AppRoute.values.map((route) => route.path).toSet();

      expect(paths.length, AppRoute.values.length);
    });
  });

  group('onGenerateAppRoute', () {
    test('should build the home route', () {
      final route = onGenerateAppRoute(const RouteSettings(name: '/'));

      expect(route, isNotNull);
      expect(route!.settings.name, '/');
    });

    test('should build the account route', () {
      final route = onGenerateAppRoute(const RouteSettings(name: '/account'));

      expect(route, isNotNull);
      expect(route!.settings.name, '/account');
    });

    test('should build a legal route for a legal text', () {
      final route = onGenerateAppRoute(
        const RouteSettings(
          name: '/account/legal',
          arguments: LegalDocumentKind.privacy,
        ),
      );

      expect(route, isNotNull);
      expect(route!.settings.arguments, LegalDocumentKind.privacy);
    });

    test('should reject a legal route without a legal text', () {
      expect(
        onGenerateAppRoute(const RouteSettings(name: '/account/legal')),
        isNull,
      );
      expect(
        onGenerateAppRoute(
          const RouteSettings(name: '/account/legal', arguments: 'terms'),
        ),
        isNull,
      );
    });

    test('should reject an unknown route', () {
      expect(onGenerateAppRoute(const RouteSettings(name: '/x')), isNull);
    });
  });

  testWidgets('should open the legal text named by the argument', (
    tester,
  ) async {
    final bundle = FakeAssetBundle({
      'assets/legal/privacy.txt': '# Data\n\nNothing is collected.',
    });
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: MaterialApp(
          theme: buildSolennTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: onGenerateAppRoute,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).pushNamed<void>(
                AppRoute.accountLegal.path,
                arguments: LegalDocumentKind.privacy,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Nothing is collected.'), findsOneWidget);
  });
}
