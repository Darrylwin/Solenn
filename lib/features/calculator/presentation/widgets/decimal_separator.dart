import 'package:intl/intl.dart';

final RegExp _digits = RegExp(r'\p{Nd}', unicode: true);
final RegExp _directionMarks = RegExp('[\u200E\u200F]');

/// The decimal separator used by the locale named [localeName].
///
/// It is derived from a formatted sample so that every script is supported
/// without maintaining a table.
String decimalSeparatorFor(String localeName) {
  final sample = NumberFormat.decimalPattern(localeName).format(0.5);
  return sample.replaceAll(_digits, '').replaceAll(_directionMarks, '');
}
