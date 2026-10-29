import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solenn/app/app.dart';
import 'package:solenn/app/app_dependencies.dart';
import 'package:solenn/app/error_fallback.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/core/services/app_bloc_observer.dart';
import 'package:solenn/core/services/app_info.dart';
import 'package:solenn/core/services/app_logger.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/subscription/domain/flow/subscription_timings.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';

/// Composition root: installs global hooks, builds [AppDependencies] and
/// starts the application.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  const logger = AppLogger();

  FlutterError.onError = (details) {
    logger.error(
      'Unhandled framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'Unhandled platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };
  if (kDebugMode) Bloc.observer = const AppBlocObserver(logger);
  installErrorFallback(enabled: kReleaseMode);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(solennSystemUiOverlayStyle);
  _registerFontLicenses();

  final packageInfo = await PackageInfo.fromPlatform();
  final dependencies = AppDependencies(
    logger: logger,
    haptics: const SystemHapticsService(),
    clipboard: const SystemClipboardService(),
    appInfo: AppInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    ),
    sabotageEngine: SabotageEngine(
      random: Random(DateTime.now().microsecondsSinceEpoch),
    ),
    pricingCatalog: PricingCatalog.standard,
    subscriptionTimings: SubscriptionTimings.standard,
  );

  runApp(SolennApp(dependencies: dependencies));
}

/// Makes the bundled font license appear on the licenses page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/manrope/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Manrope'], text);
  });
}
