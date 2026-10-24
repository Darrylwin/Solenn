import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_key_spec.dart';
import 'package:solenn/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  CalculatorKeySpec specOf(CalculatorKey key, {String separator = '.'}) =>
      calculatorKeySpec(key, l10n: l10n, decimalSeparator: separator);

  group('calculatorKeySpec', () {
    test('should describe every key with a spoken label', () {
      for (final key in CalculatorKey.values) {
        final spec = specOf(key);

        expect(spec.semanticLabel, isNotEmpty, reason: '$key');
        expect(spec.label != null || spec.icon != null, isTrue, reason: '$key');
      }
    });

    test('should label digit keys with their digit', () {
      final spec = specOf(CalculatorKey.seven);

      expect(spec.label, '7');
      expect(spec.semanticLabel, '7');
      expect(spec.variant, SolennKeyVariant.digit);
    });

    test('should use the locale decimal separator', () {
      expect(specOf(CalculatorKey.decimalSeparator, separator: ',').label, ',');
    });

    test('should give every operator the accent variant', () {
      final operators = CalculatorKey.values.where((key) => key.isOperator);

      for (final key in [...operators, CalculatorKey.equals]) {
        expect(specOf(key).variant, SolennKeyVariant.accent, reason: '$key');
      }
    });

    test('should draw the backspace key as an icon', () {
      final spec = specOf(CalculatorKey.backspace);

      expect(spec.icon, Icons.backspace_outlined);
      expect(spec.label, isNull);
      expect(spec.variant, SolennKeyVariant.function);
    });

    test('should localize the clear key', () {
      expect(specOf(CalculatorKey.clear).label, 'AC');
      expect(specOf(CalculatorKey.clear).semanticLabel, 'All clear');
    });

    test('should render the sign toggle as a smaller auxiliary key', () {
      expect(
        specOf(CalculatorKey.toggleSign).variant,
        SolennKeyVariant.auxiliary,
      );
    });
  });
}
