import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/formatting/operator_glyph.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

void main() {
  test('should use the typographic glyph of each operator', () {
    expect(operatorGlyph(ArithmeticOperator.add), '+');
    expect(operatorGlyph(ArithmeticOperator.subtract), '\u2212');
    expect(operatorGlyph(ArithmeticOperator.multiply), '\u00D7');
    expect(operatorGlyph(ArithmeticOperator.divide), '\u00F7');
  });

  test('should give every operator its own glyph', () {
    final glyphs = ArithmeticOperator.values.map(operatorGlyph).toSet();

    expect(glyphs.length, ArithmeticOperator.values.length);
  });

  test('should not confuse the subtraction glyph with the negative sign', () {
    expect(operatorGlyph(ArithmeticOperator.subtract), isNot('-'));
  });
}
