import 'package:flutter/widgets.dart';
import 'package:solenn/l10n/app_localizations.dart';

export 'package:solenn/l10n/app_localizations.dart';

/// Shorthand access to the generated localizations.
extension AppLocalizationsContext on BuildContext {
  /// The localized strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
