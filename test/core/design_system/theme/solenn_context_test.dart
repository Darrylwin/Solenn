import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

import '../../../helpers/pump_screen.dart';

const Duration _duration = Duration(milliseconds: 160);

Future<Duration> _adapted(
  WidgetTester tester, {
  required bool disableAnimations,
}) async {
  late Duration adapted;
  await pumpScreen(
    tester,
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: Builder(
          builder: (inner) {
            adapted = inner.adaptiveDuration(_duration);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return adapted;
}

void main() {
  group('adaptiveDuration', () {
    testWidgets('should keep the duration by default', (tester) async {
      expect(await _adapted(tester, disableAnimations: false), _duration);
    });

    testWidgets('should be zero when the user asked for less motion', (
      tester,
    ) async {
      expect(await _adapted(tester, disableAnimations: true), Duration.zero);
    });
  });
}
