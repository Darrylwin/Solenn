import 'package:flutter/material.dart';
import 'package:solenn/app/account_screen.dart';
import 'package:solenn/app/home_screen.dart';
import 'package:solenn/app/router/app_route.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';
import 'package:solenn/features/account/presentation/legal/legal_page.dart';

/// Route factory of the application's navigator.
///
/// It returns `null` for an unknown name, and for a legal route whose
/// argument is not a [LegalDocumentKind].
Route<void>? onGenerateAppRoute(RouteSettings settings) {
  final route = AppRoute.fromPath(settings.name);
  if (route == null) return null;

  return switch (route) {
    AppRoute.home => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const HomeScreen(),
    ),
    AppRoute.account => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const AccountScreen(),
    ),
    AppRoute.accountLegal => _legalRoute(settings),
  };
}

Route<void>? _legalRoute(RouteSettings settings) {
  final kind = settings.arguments;
  if (kind is! LegalDocumentKind) return null;

  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => LegalPage(kind: kind),
  );
}
