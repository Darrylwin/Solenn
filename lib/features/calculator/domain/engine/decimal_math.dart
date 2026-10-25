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
final RegExp _leadingZeros = RegExp('^0+');

typedef _Parts = ({bool negative, BigInt unscaled, int scale});

/// The significant digits of a nonzero decimal and its magnitude.
///
/// `digits` has no leading zero. `exponent` is the power of ten of the first
/// digit: 4 for 24220, -2 for 0.0333.
typedef DecimalDigits = ({bool negative, String digits, int exponent});

/// Whether [value] is zero.
bool isZero(Decimal value) => value.compareTo(_zero) == 0;

/// Whether [value] is strictly below zero.
bool isNegative(Decimal value) => value.compareTo(_zero) < 0;

/// The plain decimal text of [value]: ASCII digits, an optional leading `-`
/// and an optional `.`, without exponent, trailing zeros or negative zero.
String canonicalText(Decimal value) {
  final text = value.toString();
  final trimmed = text.contains('.')
      ? text.replaceFirst(_trailingZeros, '')
      : text;
  return trimmed == '-0' ? '0' : trimmed;
}

/// The significant digits and the magnitude of [value], which must not be zero.
DecimalDigits decimalDigitsOf(Decimal value) {
  assert(!isZero(value), 'Zero has no significant digit.');

  final text = canonicalText(value);
  final negative = text.startsWith('-');
  final body = negative ? text.substring(1) : text;
  final point = body.indexOf('.');
  final integer = point < 0 ? body : body.substring(0, point);
  final fraction = point < 0 ? '' : body.substring(point + 1);

  final digits = '$integer$fraction'.replaceFirst(_leadingZeros, '');
  final exponent = integer != '0'
      ? integer.length - 1
      : -(fraction.length -
            fraction.replaceFirst(_leadingZeros, '').length +
            1);

  return (negative: negative, digits: digits, exponent: exponent);
}

/// The decimal written with the given significant digits and magnitude.
///
/// It is the inverse of [decimalDigitsOf].
Decimal decimalFromDigits(DecimalDigits value) {
  final digits = value.digits;
  final exponent = value.exponent;

  final String body;
  if (exponent >= digits.length - 1) {
    body = '$digits${'0' * (exponent - digits.length + 1)}';
  } else if (exponent >= 0) {
    body =
        '${digits.substring(0, exponent + 1)}.'
        '${digits.substring(exponent + 1)}';
  } else {
    body = '0.${'0' * (-exponent - 1)}$digits';
  }
  return Decimal.parse('${value.negative ? '-' : ''}$body');
}

/// The power of ten of the first significant digit of [value], which must not
/// be zero.
int leadingExponent(Decimal value) => decimalDigitsOf(value).exponent;

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

/// [value] rounded to the nearest multiple of 10 to the [power], half away
/// from zero. [power] is positive: 3 rounds to the nearest thousand.
Decimal roundToPowerOfTen(Decimal value, int power) {
  assert(power > 0, 'Only coarser-than-unit rounding is supported.');

  final parts = _decompose(value);
  final dropped = parts.scale + power;
  final divisor = _ten.pow(dropped);
  var kept = parts.unscaled ~/ divisor;
  if ((parts.unscaled % divisor) * BigInt.two >= divisor) kept += BigInt.one;

  return _compose(negative: parts.negative, unscaled: kept, scale: -power);
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
  if (unscaled == BigInt.zero) return _zero;

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
