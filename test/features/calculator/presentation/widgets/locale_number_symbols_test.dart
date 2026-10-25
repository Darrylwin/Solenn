import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/formatting/number_symbols.dart';
import 'package:solenn/features/calculator/presentation/widgets/locale_number_symbols.dart';

void main() {
  group('numberSymbolsFor', () {
    test('should read English symbols', () {
      expect(numberSymbolsFor('en'), NumberSymbols.english);
    });

    test('should read German symbols', () {
      final symbols = numberSymbolsFor('de');

      expect(symbols.decimalSeparator, ',');
      expect(symbols.groupSeparator, '.');
    });

    test('should read French symbols', () {
      final symbols = numberSymbolsFor('fr');

      expect(symbols.decimalSeparator, ',');
      // A narrow or plain no-break space, depending on the intl version.
      expect(symbols.groupSeparator, matches(RegExp(r'^\s$')));
    });

    test('should always provide a minus sign', () {
      for (final locale in ['en', 'fr', 'de', 'ar', 'sv']) {
        expect(numberSymbolsFor(locale).minusSign, isNotEmpty, reason: locale);
      }
    });

    test('should never return a digit as a symbol', () {
      final digits = RegExp(r'\p{Nd}', unicode: true);

      for (final locale in ['en', 'fr', 'de', 'ar', 'hi']) {
        final symbols = numberSymbolsFor(locale);

        expect(digits.hasMatch(symbols.decimalSeparator), isFalse);
        expect(digits.hasMatch(symbols.groupSeparator), isFalse);
      }
    });
  });
}
