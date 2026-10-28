import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';
import 'package:solenn/features/account/presentation/legal/legal_page.dart';
import 'package:solenn/features/account/presentation/legal/legal_view.dart';

import '../../../../helpers/fake_asset_bundle.dart';
import '../../../../helpers/pump_screen.dart';

const String _terms = '''
# Acceptance

You accept these terms.

# Use

Use Solenn as it is.
''';

const String _privacy = '''
# Data

Nothing is collected.
''';

FakeAssetBundle _bundle({Future<void>? gate}) => FakeAssetBundle({
  'assets/legal/terms.txt': _terms,
  'assets/legal/privacy.txt': _privacy,
}, gate: gate);

Widget _page(LegalDocumentKind kind, FakeAssetBundle bundle) =>
    DefaultAssetBundle(
      bundle: bundle,
      child: LegalPage(kind: kind),
    );

void main() {
  group('content', () {
    testWidgets('should show the terms once loaded', (tester) async {
      await pumpScreen(tester, _page(LegalDocumentKind.terms, _bundle()));
      await tester.pumpAndSettle();

      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Acceptance'), findsOneWidget);
      expect(find.text('You accept these terms.'), findsOneWidget);
      expect(find.text('Nothing is collected.'), findsNothing);
    });

    testWidgets('should show the privacy policy once loaded', (tester) async {
      await pumpScreen(tester, _page(LegalDocumentKind.privacy, _bundle()));
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Nothing is collected.'), findsOneWidget);
      expect(find.text('You accept these terms.'), findsNothing);
    });
  });

  group('loading', () {
    testWidgets('should keep the title and the back button while loading', (
      tester,
    ) async {
      final gate = Completer<void>();
      await pumpScreen(
        tester,
        _page(LegalDocumentKind.terms, _bundle(gate: gate.future)),
      );

      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.byType(SolennBackButton), findsOneWidget);
      expect(find.byType(LegalView), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(LegalView), findsOneWidget);
      expect(find.text('Acceptance'), findsOneWidget);
    });

    testWidgets('should stay usable when the text cannot be loaded', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _page(LegalDocumentKind.terms, FakeAssetBundle({})),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LegalView), findsNothing);
      expect(find.byType(SolennBackButton), findsOneWidget);
    });
  });

  testWidgets('should go back when the back button is tapped', (tester) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => unawaited(
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _page(LegalDocumentKind.terms, _bundle()),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(LegalPage), findsOneWidget);

    await tester.tap(find.byType(SolennBackButton));
    await tester.pumpAndSettle();

    expect(find.byType(LegalPage), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  group('layout', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('should not overflow at x2 on $platform', (tester) async {
        await pumpScreen(
          tester,
          _page(LegalDocumentKind.terms, _bundle()),
          platform: platform,
          size: const Size(320, 568),
          textScale: 2,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
