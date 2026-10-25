import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

/// The character that stands for [operation] in an expression and on its key.
///
/// Escapes are used on purpose: the subtraction sign is U+2212 (minus), which
/// is visually close to the hyphen that signs a negative number.
String operatorGlyph(ArithmeticOperator operation) => switch (operation) {
  ArithmeticOperator.add => '+',
  ArithmeticOperator.subtract => '\u2212',
  ArithmeticOperator.multiply => '\u00D7',
  ArithmeticOperator.divide => '\u00F7',
};
