import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/formatting/number_formatter.dart';

/// What the user would read for [value]: its text rounded to the digits of the
/// display. Two values with the same key look identical on screen.
String displayKey(Decimal value) => canonicalText(
  roundToSignificantDigits(value, digits: displayDigits),
);
