import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/app/app_dependencies.dart';
import 'package:solenn/app/router/app_route.dart';
import 'package:solenn/app/router/app_router.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/core/services/app_info.dart';
import 'package:solenn/core/services/app_logger.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/l10n/l10n.dart';

/// Root widget: installs the theme, localizations, routing and services.
class SolennApp extends StatelessWidget {
  /// Creates the application with its [dependencies].
  const SolennApp({required this.dependencies, super.key});

  /// Services injected by the composition root.
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppLogger>.value(value: dependencies.logger),
        RepositoryProvider<HapticsService>.value(value: dependencies.haptics),
        RepositoryProvider<ClipboardService>.value(
          value: dependencies.clipboard,
        ),
        RepositoryProvider<AppInfo>.value(value: dependencies.appInfo),
        RepositoryProvider<SabotageEngine>.value(
          value: dependencies.sabotageEngine,
        ),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => context.l10n.appName,
        debugShowCheckedModeBanner: false,
        theme: buildSolennTheme(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoute.home.path,
        onGenerateRoute: onGenerateAppRoute,
      ),
    );
  }
}
