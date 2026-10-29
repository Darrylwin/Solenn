import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/l10n/l10n.dart';

/// The screen that replaces a widget that failed to build, for [locale].
///
/// A locale the application has no strings for falls back to the first
/// supported one, so the screen always has something to say.
Widget buildErrorFallback({required Locale locale}) {
  final l10n = _stringsFor(locale);

  return SolennErrorFallback(
    initial: l10n.brandInitial,
    title: l10n.errorFallbackTitle,
    message: l10n.errorFallbackMessage,
    textDirection: Bidi.isRtlLanguage(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr,
  );
}

/// Replaces the framework's red error screen with [buildErrorFallback] when
/// [enabled], which `bootstrap` sets for release builds only: debug builds
/// keep the red screen, which says what went wrong.
///
/// The builder has no context, so the locale comes from the platform.
void installErrorFallback({required bool enabled}) {
  if (!enabled) return;

  ErrorWidget.builder = (_) => buildErrorFallback(
    locale: WidgetsBinding.instance.platformDispatcher.locale,
  );
}

AppLocalizations _stringsFor(Locale locale) {
  final supported = AppLocalizations.delegate.isSupported(locale);
  return lookupAppLocalizations(
    supported ? locale : AppLocalizations.supportedLocales.first,
  );
}
