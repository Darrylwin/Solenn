import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/domain/formatting/operator_glyph.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/l10n/l10n.dart';

const String _equals = '=';
const String _percent = '%';
const String _toggleSign = '+/−';

/// How a [CalculatorKey] is presented.
@immutable
class CalculatorKeySpec {
  /// Creates a presentation for one key.
  const CalculatorKeySpec({
    required this.variant,
    required this.semanticLabel,
    this.label,
    this.icon,
  });

  /// Visual role.
  final SolennKeyVariant variant;

  /// Spoken description.
  final String semanticLabel;

  /// Visible text, when the key shows text.
  final String? label;

  /// Visible icon, when the key shows an icon.
  final IconData? icon;
}

CalculatorKeySpec _digit(int digit) => CalculatorKeySpec(
  variant: SolennKeyVariant.digit,
  label: '$digit',
  semanticLabel: '$digit',
);

/// Presentation of [key]: glyph, spoken label and visual role.
///
/// [decimalSeparator] is the glyph of the locale (see `decimalSeparatorFor`).
CalculatorKeySpec calculatorKeySpec(
  CalculatorKey key, {
  required AppLocalizations l10n,
  required String decimalSeparator,
}) {
  return switch (key) {
    CalculatorKey.zero => _digit(0),
    CalculatorKey.one => _digit(1),
    CalculatorKey.two => _digit(2),
    CalculatorKey.three => _digit(3),
    CalculatorKey.four => _digit(4),
    CalculatorKey.five => _digit(5),
    CalculatorKey.six => _digit(6),
    CalculatorKey.seven => _digit(7),
    CalculatorKey.eight => _digit(8),
    CalculatorKey.nine => _digit(9),
    CalculatorKey.decimalSeparator => CalculatorKeySpec(
      variant: SolennKeyVariant.digit,
      label: decimalSeparator,
      semanticLabel: l10n.keyDecimalSemantics,
    ),
    CalculatorKey.toggleSign => CalculatorKeySpec(
      variant: SolennKeyVariant.auxiliary,
      label: _toggleSign,
      semanticLabel: l10n.keyToggleSignSemantics,
    ),
    CalculatorKey.percent => CalculatorKeySpec(
      variant: SolennKeyVariant.function,
      label: _percent,
      semanticLabel: l10n.keyPercentSemantics,
    ),
    CalculatorKey.clear => CalculatorKeySpec(
      variant: SolennKeyVariant.function,
      label: l10n.keyClearLabel,
      semanticLabel: l10n.keyClearSemantics,
    ),
    CalculatorKey.backspace => CalculatorKeySpec(
      variant: SolennKeyVariant.function,
      icon: Icons.backspace_outlined,
      semanticLabel: l10n.keyBackspaceSemantics,
    ),
    CalculatorKey.add => CalculatorKeySpec(
      variant: SolennKeyVariant.accent,
      label: operatorGlyph(ArithmeticOperator.add),
      semanticLabel: l10n.keyAddSemantics,
    ),
    CalculatorKey.subtract => CalculatorKeySpec(
      variant: SolennKeyVariant.accent,
      label: operatorGlyph(ArithmeticOperator.subtract),
      semanticLabel: l10n.keySubtractSemantics,
    ),
    CalculatorKey.multiply => CalculatorKeySpec(
      variant: SolennKeyVariant.accent,
      label: operatorGlyph(ArithmeticOperator.multiply),
      semanticLabel: l10n.keyMultiplySemantics,
    ),
    CalculatorKey.divide => CalculatorKeySpec(
      variant: SolennKeyVariant.accent,
      label: operatorGlyph(ArithmeticOperator.divide),
      semanticLabel: l10n.keyDivideSemantics,
    ),
    CalculatorKey.equals => CalculatorKeySpec(
      variant: SolennKeyVariant.accent,
      label: _equals,
      semanticLabel: l10n.keyEqualsSemantics,
    ),
  };
}
