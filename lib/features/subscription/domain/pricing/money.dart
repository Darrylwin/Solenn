import 'package:equatable/equatable.dart';

/// An amount of money in the minor unit of its currency (cents for US
/// dollars).
///
/// Arithmetic stays on integers, so no rounding error can creep into a price.
/// Only currencies with two minor digits are supported.
class Money extends Equatable {
  /// Creates an amount of [amountMinor] cents of the currency [currencyCode].
  const Money({required this.amountMinor, required this.currencyCode})
    : assert(amountMinor >= 0, 'An amount cannot be negative.'),
      assert(currencyCode.length == 3, 'A currency code has three letters.');

  /// Creates an amount of US dollars from [amountMinor] cents.
  const Money.usd(int amountMinor)
    : this(amountMinor: amountMinor, currencyCode: 'USD');

  /// The amount in the minor unit of the currency.
  final int amountMinor;

  /// The ISO 4217 code of the currency, for example `USD`.
  final String currencyCode;

  /// This amount repeated [factor] times.
  Money times(int factor) {
    assert(factor >= 0, 'A factor cannot be negative.');
    return Money(
      amountMinor: amountMinor * factor,
      currencyCode: currencyCode,
    );
  }

  /// This amount split into [divisor] equal parts, rounded half up to the
  /// nearest minor unit.
  Money dividedBy(int divisor) {
    assert(divisor > 0, 'The divisor must be positive.');
    return Money(
      amountMinor: _roundedQuotient(amountMinor, divisor),
      currencyCode: currencyCode,
    );
  }

  /// The whole percentage by which this amount is below [reference], rounded
  /// half up. Zero means the two amounts are equal.
  ///
  /// Both amounts must share a currency, [reference] must be positive and this
  /// amount must not exceed it.
  int percentBelow(Money reference) {
    if (reference.currencyCode != currencyCode) {
      throw ArgumentError.value(
        reference,
        'reference',
        'Must share the currency $currencyCode.',
      );
    }
    assert(reference.amountMinor > 0, 'The reference must be positive.');
    assert(
      amountMinor <= reference.amountMinor,
      'The amount must not exceed the reference.',
    );

    final difference = reference.amountMinor - amountMinor;
    return _roundedQuotient(difference * 100, reference.amountMinor);
  }

  // Integer division rounded half up: (2a + b) / 2b.
  static int _roundedQuotient(int dividend, int divisor) =>
      (2 * dividend + divisor) ~/ (2 * divisor);

  @override
  List<Object> get props => [amountMinor, currencyCode];
}
