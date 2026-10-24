import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/app.dart';
import 'package:solenn/app/home_screen.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../helpers/test_dependencies.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(SolennApp(dependencies: buildTestDependencies()));
    await tester.pumpAndSettle();
  }

  testWidgets('should show the product name when launched', (tester) async {
    await pumpApp(tester);

    expect(find.text('Solenn'), findsOneWidget);
  });

  testWidgets('should expose the design tokens through the theme', (
    tester,
  ) async {
    await pumpApp(tester);

    final context = tester.element(find.byType(HomeScreen));

    expect(context.colors, same(SolennColors.dark));
    expect(context.type, same(SolennTypography.standard));
    expect(context.spacing, same(SolennSpacing.standard));
  });
}
