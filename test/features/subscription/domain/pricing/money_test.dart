import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/pricing/money.dart';

Money _money(int amount, [String currency = 'USD']) =>
    Money(amountMinor: amount, currencyCode: currency);

void main() {
  group('construction', () {
    test('should hold an amount and a currency', () {
      final money = _money(3999);

      expect(money.amountMinor, 3999);
      expect(money.currencyCode, 'USD');
    });

    test('should build US dollars', () {
      expect(const Money.usd(499), _money(499));
    });

    test('should accept zero', () {
      expect(_money(0).amountMinor, 0);
    });

    test('should refuse a negative amount', () {
      expect(() => _money(-1), throwsA(isA<AssertionError>()));
    });

    test('should refuse a currency code that is not three letters', () {
      expect(() => _money(1, 'US'), throwsA(isA<AssertionError>()));
      expect(() => _money(1, 'USDX'), throwsA(isA<AssertionError>()));
    });

    test('should compare by amount and currency', () {
      expect(_money(5), _money(5));
      expect(_money(5), isNot(_money(6)));
      expect(_money(5), isNot(_money(5, 'EUR')));
    });
  });

  group('times', () {
    test('should repeat the amount', () {
      expect(_money(499).times(12), _money(5988));
      expect(_money(499).times(1), _money(499));
      expect(_money(499).times(0), _money(0));
    });

    test('should keep the currency', () {
      expect(_money(5, 'EUR').times(2).currencyCode, 'EUR');
    });

    test('should refuse a negative factor', () {
      expect(() => _money(5).times(-1), throwsA(isA<AssertionError>()));
    });
  });

  group('dividedBy', () {
    final cases = <(int, int, int)>[
      (3999, 12, 333),
      (4, 3, 1),
      (5, 3, 2),
      (5, 2, 3),
      (7, 2, 4),
      (6, 2, 3),
      (0, 7, 0),
      (1, 1, 1),
      (999, 1000, 1),
      (499, 1000, 0),
    ];

    for (final (amount, divisor, expected) in cases) {
      test('$amount / $divisor should round half up to $expected', () {
        expect(_money(amount).dividedBy(divisor), _money(expected));
      });
    }

    test('should keep the currency', () {
      expect(_money(10, 'EUR').dividedBy(2).currencyCode, 'EUR');
    });

    test('should refuse a divisor that is not positive', () {
      expect(() => _money(5).dividedBy(0), throwsA(isA<AssertionError>()));
      expect(() => _money(5).dividedBy(-1), throwsA(isA<AssertionError>()));
    });
  });

  group('percentBelow', () {
    final cases = <(int, int, int)>[
      (3999, 5988, 33),
      (50, 100, 50),
      (100, 100, 0),
      (0, 100, 100),
      (199, 200, 1),
      (1, 3, 67),
      (2, 3, 33),
      (90, 100, 10),
    ];

    for (final (amount, reference, expected) in cases) {
      test('$amount below $reference should be $expected percent', () {
        expect(_money(amount).percentBelow(_money(reference)), expected);
      });
    }

    test('should refuse another currency', () {
      expect(
        () => _money(5).percentBelow(_money(10, 'EUR')),
        throwsArgumentError,
      );
    });

    test('should refuse a reference that is not positive', () {
      expect(
        () => _money(0).percentBelow(_money(0)),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should refuse an amount above its reference', () {
      expect(
        () => _money(11).percentBelow(_money(10)),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
