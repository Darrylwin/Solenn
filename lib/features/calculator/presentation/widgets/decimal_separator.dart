import 'package:solenn/features/calculator/presentation/widgets/locale_number_symbols.dart';

/// The decimal separator used by the locale named [localeName].
String decimalSeparatorFor(String localeName) =>
    numberSymbolsFor(localeName).decimalSeparator;
