import 'package:equatable/equatable.dart';

/// The characters a locale uses to write numbers.
///
/// The domain never reads the device locale. The presentation layer derives
/// these symbols from it and hands them over, which keeps formatting pure.
/// Digits are always ASCII, whatever the locale.
class NumberSymbols extends Equatable {
  /// Creates a set of symbols.
  const NumberSymbols({
    required this.decimalSeparator,
    required this.groupSeparator,
    this.minusSign = '-',
  });

  /// English symbols: `1,234.5`.
  static const NumberSymbols english = NumberSymbols(
    decimalSeparator: '.',
    groupSeparator: ',',
  );

  /// Separates the integer part from the fraction.
  final String decimalSeparator;

  /// Separates groups of three integer digits. Empty disables grouping.
  final String groupSeparator;

  /// Written before a negative number and before a negative exponent.
  final String minusSign;

  @override
  List<Object> get props => [decimalSeparator, groupSeparator, minusSign];
}
