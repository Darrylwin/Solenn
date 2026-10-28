import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';
import 'package:solenn/features/subscription/domain/pricing/money_formatter.dart';

void main() {
  group('formatMoney in US dollars', () {
    final _ =
        {
          0: r'$0.00',
          5: r'$0.05',
          99: r'$0.99',
          100: r'$1.00',
          499: r'$4.99',
          3999: r'$39.99',
          5988: r'$59.88',
          14999: r'$149.99',
          99999: r'$999.99',
          100000: r'$1,000.00',
          123456789: r'$1,234,567.89',
        }..forEach((cents, expected) {
          test('$cents cents should read $expected', () {
            expect(formatMoney(Money.usd(cents)), expected);
          });
        });
  });

  group('formatMoney in another currency', () {
    test('should prefix the code of a currency without a known symbol', () {
      expect(
        formatMoney(const Money(amountMinor: 1050, currencyCode: 'EUR')),
        'EUR 10.50',
      );
    });

    test('should group the thousands', () {
      expect(
        formatMoney(const Money(amountMinor: 123456, currencyCode: 'EUR')),
        'EUR 1,234.56',
      );
    });
  });
}
