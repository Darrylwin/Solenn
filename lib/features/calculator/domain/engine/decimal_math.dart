import 'package:decimal/decimal.dart';

/// Significant digits kept after every operation.
const int significantDigits = 15;

/// Largest decimal exponent a result may have, in either direction.
///
/// A result of 1e100 or more, or a nonzero one below 1e-99, is out of range.
const int maxExponent = 99;

// Fractional digits kept when a quotient has no finite expansion. It exceeds
// maxExponent + significantDigits so that the smallest representable result
// keeps every significant digit until it is rounded.
const int _divisionScale = 120;

final Decimal _zero = Decimal.parse('0');
final Decimal _hundredth = Decimal.parse('0.01');
final BigInt _ten = BigInt.from(10);
final RegExp _trailingZeros = RegExp(r'\.?0+$');

typedef _Parts = ({bool negative, BigInt unscaled, int scale});

/// Whether [value] is zero.
bool isZero(Decimal value) => value.compareTo(_zero) == 0;

/// The plain decimal text of [value]: ASCII digits, an optional leading `-`
/// and an optional `.`, without exponent, trailing zeros or negative zero.
String canonicalText(Decimal value) {
  final text = value.toString();
  final trimmed = text.contains('.')
      ? text.replaceFirst(_trailingZeros, '')
      : text;
  return trimmed == '-0' ? '0' : trimmed;
}

/// [value] rounded to [digits] significant digits, half away from zero.
///
/// A value that already fits is returned unchanged.
Decimal roundToSignificantDigits(
  Decimal value, {
  int digits = significantDigits,
}) {
  assert(digits > 0, 'At least one significant digit is required.');

  final parts = _decompose(value);
  final length = parts.unscaled.toString().length;
  if (parts.unscaled == BigInt.zero || length <= digits) return value;

  final dropped = length - digits;
  final divisor = _ten.pow(dropped);
  var kept = parts.unscaled ~/ divisor;
  if ((parts.unscaled % divisor) * BigInt.two >= divisor) kept += BigInt.one;

  return _compose(
    negative: parts.negative,
    unscaled: kept,
    scale: parts.scale - dropped,
  );
}

/// Whether the magnitude of [value] is beyond [maxExponent] in either
/// direction. Zero is always in range.
bool isOutOfRange(Decimal value) {
  final parts = _decompose(value);
  if (parts.unscaled == BigInt.zero) return false;

  final exponent = parts.unscaled.toString().length - parts.scale - 1;
  return exponent > maxExponent || exponent < -maxExponent;
}

/// [dividend] divided by [divisor], or `null` when [divisor] is zero.
///
/// A quotient without finite expansion is truncated at a scale far beyond
/// what [roundToSignificantDigits] keeps, which makes the later half-up
/// rounding exact.
Decimal? divideDecimal(Decimal dividend, Decimal divisor) {
  if (isZero(divisor)) return null;
  return (dividend / divisor).toDecimal(
    scaleOnInfinitePrecision: _divisionScale,
  );
}

/// [value] as a percentage: one hundredth of it.
Decimal percentValue(Decimal value) => value * _hundredth;

_Parts _decompose(Decimal value) {
  var text = value.toString();
  final negative = text.startsWith('-');
  if (negative) text = text.substring(1);

  final point = text.indexOf('.');
  final integer = point < 0 ? text : text.substring(0, point);
  final fraction = point < 0 ? '' : text.substring(point + 1);

  return (
    negative: negative,
    unscaled: BigInt.parse('$integer$fraction'),
    scale: fraction.length,
  );
}

Decimal _compose({
  required bool negative,
  required BigInt unscaled,
  required int scale,
}) {
  final digits = unscaled.toString();
  final String text;
  if (scale <= 0) {
    text = '$digits${'0' * -scale}';
  } else {
    final padded = digits.padLeft(scale + 1, '0');
    final split = padded.length - scale;
    text = '${padded.substring(0, split)}.${padded.substring(split)}';
  }
  return Decimal.parse('${negative ? '-' : ''}$text');
}
