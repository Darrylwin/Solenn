import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/app/paywall_route.dart';

import '../helpers/pump_screen.dart';

Future<BuildContext> _pumpContext(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  late BuildContext captured;
  await pumpScreen(
    tester,
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
        ),
        child: Builder(
          builder: (inner) {
            captured = inner;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets('should slide up over the standard duration', (tester) async {
    final context = await _pumpContext(tester);

    final route = buildPaywallRoute(context, builder: (_) => const SizedBox());

    expect(route.fullscreenDialog, isTrue);
    expect(route.transitionDuration, const Duration(milliseconds: 360));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 240));
  });

  testWidgets('should fade quickly when animations are disabled', (
    tester,
  ) async {
    final context = await _pumpContext(tester, disableAnimations: true);

    final route = buildPaywallRoute(context, builder: (_) => const SizedBox());

    expect(route.transitionDuration, const Duration(milliseconds: 120));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 120));
  });
}
