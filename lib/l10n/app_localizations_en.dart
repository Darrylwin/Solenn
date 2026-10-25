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

  @override
  String get brandInitial => 'S';

  @override
  String get paywallBrandName => 'solenn';

  @override
  String get paywallBrandTier => 'plus';

  @override
  String get paywallCloseSemantics => 'Close';

  @override
  String get paywallTitleLead => 'Unlock';

  @override
  String get paywallTitleAccent => 'Precision™';

  @override
  String get paywallSubtitle =>
      'Continue calculating with Solenn Plus. Unlimited results, every time.';

  @override
  String paywallSocialProof(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Trusted by $countString professionals';
  }

  @override
  String get paywallDecline => 'I prefer inaccurate results';

  @override
  String get paywallRestore => 'Restore';

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPrivacy => 'Privacy';

  @override
  String paywallOfferCountdown(String time) {
    return 'Offer ends in $time';
  }

  @override
  String get checkoutProductName => 'Solenn Plus';

  @override
  String get checkoutDueToday => 'Due today';

  @override
  String get checkoutConfirm => 'Confirm subscription';

  @override
  String get checkoutCancel => 'Cancel';

  @override
  String get checkoutRenewalNotice =>
      'Renews automatically unless cancelled at least 24 hours before the end of the current period.';
}
