import 'package:intl/intl.dart';
import 'package:solenn/features/calculator/domain/formatting/number_symbols.dart';

final RegExp _digits = RegExp(r'\p{Nd}', unicode: true);
final RegExp _invisibleMarks = RegExp('[\u200E\u200F\u061C]');
const String _fallbackMinusSign = '-';

// Samples whose formatting reveals one symbol each once digits are removed.
const num _fractionSample = 0.5;
const int _groupingSample = 1234567;
const int _negativeSample = -1;

String _withoutDigits(String formatted) =>
    formatted.replaceAll(_digits, '').replaceAll(_invisibleMarks, '');

/// The symbols used by the locale named [localeName].
///
/// They are read from formatted samples instead of a table, so every locale
/// `intl` knows is supported. Grouping is always by three digits.
NumberSymbols numberSymbolsFor(String localeName) {
  final format = NumberFormat.decimalPattern(localeName);

  // 1234567 holds two group separators; one of them is the symbol.
  final separators = _withoutDigits(format.format(_groupingSample));
  final minus = _withoutDigits(format.format(_negativeSample));

  return NumberSymbols(
    decimalSeparator: _withoutDigits(format.format(_fractionSample)),
    groupSeparator: separators.substring(0, separators.length ~/ 2),
    minusSign: minus.isEmpty ? _fallbackMinusSign : minus,
  );
}
