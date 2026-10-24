import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/presentation/widgets/decimal_separator.dart';

void main() {
  group('decimalSeparatorFor', () {
    test('should use a point for English', () {
      expect(decimalSeparatorFor('en'), '.');
    });

    test('should use a comma for French and German', () {
      expect(decimalSeparatorFor('fr'), ',');
      expect(decimalSeparatorFor('de'), ',');
    });
  });
}
