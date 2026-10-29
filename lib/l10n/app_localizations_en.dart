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

  @override
  String get backSemantics => 'Back';

  @override
  String get historyTitle => 'History';

  @override
  String get historyClear => 'Clear';

  @override
  String get historyEmpty => 'No calculations yet';

  @override
  String historyEntrySemantics(String expression, String result) {
    return '$expression equals $result';
  }

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSectionSubscription => 'SUBSCRIPTION';

  @override
  String get accountSectionLegal => 'LEGAL';

  @override
  String get accountSectionAbout => 'ABOUT';

  @override
  String get accountRestorePurchases => 'Restore purchases';

  @override
  String get accountTerms => 'Terms of Service';

  @override
  String get accountPrivacy => 'Privacy Policy';

  @override
  String get accountLicenses => 'Open-source licenses';

  @override
  String get accountVersion => 'Version';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get calculatorError => 'Error';

  @override
  String get calculatorCopied => 'Copied';

  @override
  String get calculatorCopyHint => 'Copy result';

  @override
  String get plusBadge => 'PLUS';

  @override
  String get welcomeBannerTitle => 'Welcome to Solenn Plus';

  @override
  String get welcomeBannerMessage =>
      'Your plan is active. Calculate without limits.';

  @override
  String planTitle(String plan) {
    String _temp0 = intl.Intl.selectLogic(
      plan,
      {
        'annual': 'Annual',
        'monthly': 'Monthly',
        'enterprise': 'Enterprise',
        'other': 'Plan',
      },
    );
    return '$_temp0';
  }

  @override
  String planTrial(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days-day free trial',
      one: '1-day free trial',
    );
    return '$_temp0';
  }

  @override
  String planTrialThenMonthly(String trial, String price) {
    return '$trial · $price / month';
  }

  @override
  String planMonthlyEquivalent(String price) {
    return '$price / month';
  }

  @override
  String get planSubtitleMonthly => 'Billed monthly · Cancel anytime';

  @override
  String get planSubtitleEnterprise => 'Slightly less wrong results';

  @override
  String planBestValueBadge(int percent) {
    return 'BEST VALUE · SAVE $percent%';
  }

  @override
  String pricePerPeriod(String price, String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'monthly': 'month',
        'yearly': 'year',
        'other': 'period',
      },
    );
    return '$price / $_temp0';
  }

  @override
  String priceSpokenPerPeriod(String price, String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'monthly': 'month',
        'yearly': 'year',
        'other': 'period',
      },
    );
    return '$price per $_temp0';
  }

  @override
  String planSemanticsHead(String title, String price) {
    return '$title plan, $price';
  }

  @override
  String planSemanticsSavings(int percent) {
    return 'save $percent percent';
  }

  @override
  String get planSemanticsBilledMonthly => 'billed monthly, cancel anytime';

  @override
  String ctaStartTrial(String trial) {
    return 'Start $trial';
  }

  @override
  String ctaSubscribe(String price) {
    return 'Subscribe for $price';
  }

  @override
  String finePrintAfterTrial(String price) {
    return 'Then $price';
  }

  @override
  String finePrintBilled(String price) {
    return 'Billed $price';
  }

  @override
  String checkoutPlanName(String plan) {
    String _temp0 = intl.Intl.selectLogic(
      plan,
      {
        'annual': 'Annual subscription',
        'monthly': 'Monthly subscription',
        'enterprise': 'Enterprise subscription',
        'other': 'Subscription',
      },
    );
    return '$_temp0';
  }

  @override
  String get checkoutRowTrial => 'Free trial';

  @override
  String get checkoutRowThen => 'Then';

  @override
  String get checkoutRowPrice => 'Price';

  @override
  String checkoutTrialLength(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get accountPlanFree => 'Solenn Free';

  @override
  String get accountPlanFreeDetail => 'Standard accuracy';

  @override
  String get accountPlanDismissedDetail => 'Complimentary access';

  @override
  String get accountPlanRestoredDetail => 'Restored purchase';

  @override
  String accountPlanDetailTrial(String plan, String trial) {
    return '$plan · $trial';
  }

  @override
  String get errorFallbackTitle => 'Something went wrong';

  @override
  String get errorFallbackMessage => 'Please close Solenn and open it again.';
}
