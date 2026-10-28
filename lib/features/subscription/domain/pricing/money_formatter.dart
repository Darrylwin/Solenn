import 'package:solenn/features/subscription/domain/pricing/money.dart';

const Map<String, String> _symbols = {'USD': r'$'};
const String _groupSeparator = ',';
const String _decimalSeparator = '.';
const int _groupSize = 3;
const int _minorUnitsPerMajor = 100;

/// Writes [money] as a price: `$39.99`, `$1,234.50`.
///
/// Prices are fixed to US English conventions whatever the device locale
/// (specification section 9.2). A currency without a known symbol is written
/// as its code, for example `EUR 10.50`.
String formatMoney(Money money) {
  final major = money.amountMinor ~/ _minorUnitsPerMajor;
  final minor = (money.amountMinor % _minorUnitsPerMajor).toString().padLeft(
    2,
    '0',
  );
  final prefix = _symbols[money.currencyCode] ?? '${money.currencyCode} ';

  return '$prefix${_group(major.toString())}$_decimalSeparator$minor';
}

String _group(String digits) {
  if (digits.length <= _groupSize) return digits;

  final buffer = StringBuffer();
  final head = digits.length % _groupSize;
  if (head > 0) buffer.write(digits.substring(0, head));
  for (var start = head; start < digits.length; start += _groupSize) {
    if (buffer.isNotEmpty) buffer.write(_groupSeparator);
    buffer.write(digits.substring(start, start + _groupSize));
  }
  return buffer.toString();
}
