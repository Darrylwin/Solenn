import 'package:flutter/material.dart';
import 'package:solenn/app/home_screen.dart';
import 'package:solenn/app/router/app_route.dart';

/// Route factory of the application's navigator.
Route<void>? onGenerateAppRoute(RouteSettings settings) {
  final route = AppRoute.fromPath(settings.name);
  if (route == null) return null;

  return switch (route) {
    AppRoute.home => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const HomeScreen(),
    ),
  };
}
