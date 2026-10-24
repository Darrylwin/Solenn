import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/presentation/widgets/expression_spans.dart';

void main() {
  const style = TextStyle(color: Color(0xFF123456));

  List<String> texts(List<InlineSpan> spans) =>
      spans.map((span) => (span as TextSpan).text!).toList();

  group('highlightOperators', () {
    test('should isolate each operator in its own styled span', () {
      final spans = highlightOperators('24,000+220', operatorStyle: style);

      expect(texts(spans), ['24,000', '+', '220']);
      expect((spans[1] as TextSpan).style, style);
      expect((spans[0] as TextSpan).style, isNull);
    });

    test('should recognize every operator glyph', () {
      final spans = highlightOperators('1+2−3×4÷5', operatorStyle: style);

      expect(texts(spans), ['1', '+', '2', '−', '3', '×', '4', '÷', '5']);
    });

    test('should return nothing for an empty expression', () {
      expect(highlightOperators('', operatorStyle: style), isEmpty);
    });

    test('should keep text without operator in a single span', () {
      expect(texts(highlightOperators('123', operatorStyle: style)), ['123']);
    });
  });
}
