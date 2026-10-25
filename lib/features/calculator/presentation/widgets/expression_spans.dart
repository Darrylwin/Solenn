import 'package:flutter/painting.dart';
import 'package:solenn/features/calculator/domain/formatting/operator_glyph.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';

final String _operators = ArithmeticOperator.values.map(operatorGlyph).join();

/// Splits [text] into spans so that arithmetic operators use
/// [operatorStyle] while everything else keeps the surrounding style.
List<InlineSpan> highlightOperators(
  String text, {
  required TextStyle operatorStyle,
}) {
  final spans = <InlineSpan>[];
  final plain = StringBuffer();

  void flush() {
    if (plain.isEmpty) return;
    spans.add(TextSpan(text: plain.toString()));
    plain.clear();
  }

  for (final character in text.split('')) {
    if (_operators.contains(character)) {
      flush();
      spans.add(TextSpan(text: character, style: operatorStyle));
    } else {
      plain.write(character);
    }
  }
  flush();
  return spans;
}
