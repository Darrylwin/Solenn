import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The product name, used as the application title.
  ///
  /// In en, this message translates to:
  /// **'Solenn'**
  String get appName;

  /// Accessibility label of the button that opens the calculation history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTooltip;

  /// Accessibility label of the button that opens the account screen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTooltip;

  /// Reassuring caption shown at the top of the calculator display.
  ///
  /// In en, this message translates to:
  /// **'Verified · 99.9% accuracy'**
  String get calculatorCaption;

  /// Spoken announcement of the calculator result.
  ///
  /// In en, this message translates to:
  /// **'Result {value}'**
  String calculatorResultSemantics(String value);

  /// Visible label of the key that clears the calculator.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get keyClearLabel;

  /// Accessibility label of the clear key.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get keyClearSemantics;

  /// Accessibility label of the key that deletes the last digit.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get keyBackspaceSemantics;

  /// Accessibility label of the percent key.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get keyPercentSemantics;

  /// Accessibility label of the key that flips the sign of the current number.
  ///
  /// In en, this message translates to:
  /// **'Toggle sign'**
  String get keyToggleSignSemantics;

  /// Accessibility label of the decimal separator key.
  ///
  /// In en, this message translates to:
  /// **'Decimal separator'**
  String get keyDecimalSemantics;

  /// Accessibility label of the addition key.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get keyAddSemantics;

  /// Accessibility label of the subtraction key.
  ///
  /// In en, this message translates to:
  /// **'Subtract'**
  String get keySubtractSemantics;

  /// Accessibility label of the multiplication key.
  ///
  /// In en, this message translates to:
  /// **'Multiply'**
  String get keyMultiplySemantics;

  /// Accessibility label of the division key.
  ///
  /// In en, this message translates to:
  /// **'Divide'**
  String get keyDivideSemantics;

  /// Accessibility label of the equals key.
  ///
  /// In en, this message translates to:
  /// **'Equals'**
  String get keyEqualsSemantics;

  /// Single letter drawn inside the brand mark placeholder.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get brandInitial;

  /// Lowercase product name in the paywall header lockup.
  ///
  /// In en, this message translates to:
  /// **'solenn'**
  String get paywallBrandName;

  /// Subscription tier name shown in the accent color after the product name.
  ///
  /// In en, this message translates to:
  /// **'plus'**
  String get paywallBrandTier;

  /// Accessibility label of the button that closes the paywall.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get paywallCloseSemantics;

  /// First line of the paywall headline.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get paywallTitleLead;

  /// Second line of the paywall headline, drawn in the accent color.
  ///
  /// In en, this message translates to:
  /// **'Precision™'**
  String get paywallTitleAccent;

  /// Sentence below the paywall headline.
  ///
  /// In en, this message translates to:
  /// **'Continue calculating with Solenn Plus. Unlimited results, every time.'**
  String get paywallSubtitle;

  /// Social proof line next to the star rating.
  ///
  /// In en, this message translates to:
  /// **'Trusted by {count} professionals'**
  String paywallSocialProof(int count);

  /// Link that declines the offer on the paywall.
  ///
  /// In en, this message translates to:
  /// **'I prefer inaccurate results'**
  String get paywallDecline;

  /// Footer link that restores previous purchases.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get paywallRestore;

  /// Footer link to the terms of service.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get paywallTerms;

  /// Footer link to the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get paywallPrivacy;

  /// Countdown shown under the paywall call to action.
  ///
  /// In en, this message translates to:
  /// **'Offer ends in {time}'**
  String paywallOfferCountdown(String time);

  /// Product name at the top of the purchase confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Solenn Plus'**
  String get checkoutProductName;

  /// Label of the amount charged immediately at checkout.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get checkoutDueToday;

  /// Button that confirms the purchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm subscription'**
  String get checkoutConfirm;

  /// Button that closes the purchase confirmation without subscribing.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get checkoutCancel;

  /// Legal notice at the bottom of the purchase confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically unless cancelled at least 24 hours before the end of the current period.'**
  String get checkoutRenewalNotice;

  /// Accessibility label of the button that goes back to the previous screen.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backSemantics;

  /// Title of the calculation history sheet.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// Button that erases the calculation history.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get historyClear;

  /// Message shown when the calculation history is empty.
  ///
  /// In en, this message translates to:
  /// **'No calculations yet'**
  String get historyEmpty;

  /// Spoken description of one history entry.
  ///
  /// In en, this message translates to:
  /// **'{expression} equals {result}'**
  String historyEntrySemantics(String expression, String result);

  /// Title of the account screen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Caption above the subscription actions of the account screen.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTION'**
  String get accountSectionSubscription;

  /// Caption above the legal links of the account screen.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get accountSectionLegal;

  /// Caption above the application information of the account screen.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get accountSectionAbout;

  /// Row that restores previous purchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get accountRestorePurchases;

  /// Row that opens the terms of service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get accountTerms;

  /// Row that opens the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get accountPrivacy;

  /// Row that opens the open-source licenses page.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get accountLicenses;

  /// Label of the row that shows the application version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get accountVersion;

  /// Title of the terms of service page.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// Title of the privacy policy page.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// Text shown on the calculator display when an operation cannot be computed, such as a division by zero.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get calculatorError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
