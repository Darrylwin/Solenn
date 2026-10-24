// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Solenn';

  @override
  String get historyTooltip => 'History';

  @override
  String get accountTooltip => 'Account';

  @override
  String get calculatorCaption => 'Verified · 99.9% accuracy';

  @override
  String calculatorResultSemantics(String value) {
    return 'Result $value';
  }

  @override
  String get keyClearLabel => 'AC';

  @override
  String get keyClearSemantics => 'All clear';

  @override
  String get keyBackspaceSemantics => 'Delete';

  @override
  String get keyPercentSemantics => 'Percent';

  @override
  String get keyToggleSignSemantics => 'Toggle sign';

  @override
  String get keyDecimalSemantics => 'Decimal separator';

  @override
  String get keyAddSemantics => 'Add';

  @override
  String get keySubtractSemantics => 'Subtract';

  @override
  String get keyMultiplySemantics => 'Multiply';

  @override
  String get keyDivideSemantics => 'Divide';

  @override
  String get keyEqualsSemantics => 'Equals';
}
