import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solenn/app/app.dart';
import 'package:solenn/core/services/app_info.dart';

import '../test/helpers/test_dependencies.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SolennApp launch', () {
    testWidgets('should boot to home when launched', (tester) async {
      final dependencies = buildTestDependencies();

      await tester.pumpWidget(SolennApp(dependencies: dependencies));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MaterialApp), findsOneWidget);

      // The services built by the composition root reach the widget tree.
      final context = tester.element(find.byType(MaterialApp));
      expect(
        RepositoryProvider.of<AppInfo>(context),
        same(dependencies.appInfo),
      );
    });
  });
}
