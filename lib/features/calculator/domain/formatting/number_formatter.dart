import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/formatting/number_symbols.dart';

/// Significant digits shown on the display (specification section 7.2).
const int displayDigits = 9;

// Positional notation covers 1e-6 up to (excluding) 1e9. Beyond, the number
// is written in scientific notation.
const int _maxPositionalExponent = displayDigits - 1;
const int _minPositionalExponent = -6;
const int _groupSize = 3;
const String _percentSign = '%';
const String _exponentMarker = 'e';
const String _plusSign = '+';

final RegExp _leadingZeros = RegExp('^0+');
final RegExp _trailingZeros = RegExp(r'0+$');

/// Writes numbers the way the display shows them.
class NumberFormatter {
  /// Creates a formatter that writes with [symbols].
  const NumberFormatter(this.symbols);

  /// The characters used to write numbers.
  final NumberSymbols symbols;

  /// Formats a computed or committed number.
  ///
  /// [canonical] is canonical decimal text (see `NumberToken`). It is rounded
  /// to [displayDigits] significant digits, half away from zero, and written
  /// without trailing zeros.
  ///
  /// The result is positional from 1e-6 up to 1e9 (after rounding) and
  /// scientific outside, such as `1.23456789e+9` or `1e-7`.
  String formatValue(String canonical, {bool isPercent = false}) {
    final rounded = canonicalText(
      roundToSignificantDigits(Decimal.parse(canonical), digits: displayDigits),
    );
    return _withPercent(_layout(rounded), isPercent: isPercent);
  }

  /// Formats a number being typed, exactly as typed: a trailing separator
  /// (`5.`), trailing zeros (`1.50`) and the sign of zero (`-0`) are kept.
  ///
  /// A typed number has at most nine digits, so it is never scientific.
  String formatEntry(String entry, {bool isPercent = false}) {
    final negative = entry.startsWith('-');
    final body = negative ? entry.substring(1) : entry;
    final point = body.indexOf('.');
    final integer = point < 0 ? body : body.substring(0, point);
    final fraction = point < 0
        ? ''
        : '${symbols.decimalSeparator}${body.substring(point + 1)}';
    final sign = negative ? symbols.minusSign : '';

    return _withPercent(
      '$sign${_group(integer)}$fraction',
      isPercent: isPercent,
    );
  }

  String _layout(String rounded) {
    final negative = rounded.startsWith('-');
    final body = negative ? rounded.substring(1) : rounded;
    if (body == '0') return body;

    final point = body.indexOf('.');
    final integer = point < 0 ? body : body.substring(0, point);
    final fraction = point < 0 ? '' : body.substring(point + 1);
    final sign = negative ? symbols.minusSign : '';
    final exponent = _exponentOf(integer, fraction);

    if (exponent > _maxPositionalExponent ||
        exponent < _minPositionalExponent) {
      return '$sign${_scientific(integer, fraction, exponent)}';
    }
    final decimals = fraction.isEmpty
        ? ''
        : '${symbols.decimalSeparator}$fraction';
    return '$sign${_group(integer)}$decimals';
  }

  /// Power of ten of the leading digit: 2 for 123.4, -3 for 0.0012.
  int _exponentOf(String integer, String fraction) {
    if (integer != '0') return integer.length - 1;
    final zeros =
        fraction.length - fraction.replaceFirst(_leadingZeros, '').length;
    return -(zeros + 1);
  }

  String _scientific(String integer, String fraction, int exponent) {
    final digits =
        (integer == '0'
                ? fraction.replaceFirst(_leadingZeros, '')
                : '$integer$fraction')
            .replaceFirst(_trailingZeros, '');
    final mantissa = digits.length == 1
        ? digits
        : '${digits[0]}${symbols.decimalSeparator}${digits.substring(1)}';
    final exponentSign = exponent < 0 ? symbols.minusSign : _plusSign;

    return '$mantissa$_exponentMarker$exponentSign${exponent.abs()}';
  }

  String _group(String digits) {
    if (symbols.groupSeparator.isEmpty || digits.length <= _groupSize) {
      return digits;
    }
    final buffer = StringBuffer();
    final head = digits.length % _groupSize;
    if (head > 0) buffer.write(digits.substring(0, head));
    for (var start = head; start < digits.length; start += _groupSize) {
      if (buffer.isNotEmpty) buffer.write(symbols.groupSeparator);
      buffer.write(digits.substring(start, start + _groupSize));
    }
    return buffer.toString();
  }

  String _withPercent(String text, {required bool isPercent}) =>
      isPercent ? '$text$_percentSign' : text;
}
