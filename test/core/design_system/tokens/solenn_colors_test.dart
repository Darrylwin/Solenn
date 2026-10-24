import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return (max(first, second) + 0.05) / (min(first, second) + 0.05);
}

void main() {
  const colors = SolennColors.dark;

  group('SolennColors.dark contrast', () {
    test('should keep primary text legible on the background', () {
      expect(
        _contrast(colors.textPrimary, colors.background),
        greaterThanOrEqualTo(15),
      );
    });

    test('should keep secondary text legible on background and surface', () {
      expect(
        _contrast(colors.textSecondary, colors.background),
        greaterThanOrEqualTo(7),
      );
      expect(
        _contrast(colors.textSecondary, colors.surface),
        greaterThanOrEqualTo(6),
      );
    });

    test('should keep function key labels legible', () {
      expect(
        _contrast(colors.textPrimary, colors.keyFunction),
        greaterThanOrEqualTo(6),
      );
    });

    test('should keep content on the accent legible', () {
      expect(
        _contrast(colors.onAccent, colors.accent),
        greaterThanOrEqualTo(15),
      );
    });

    test('should keep muted icons visible as non-text graphics', () {
      expect(
        _contrast(colors.iconMuted, colors.background),
        greaterThanOrEqualTo(3),
      );
    });
  });
}
