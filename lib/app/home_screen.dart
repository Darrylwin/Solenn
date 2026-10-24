import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/l10n/l10n.dart';

/// Home of the application.
///
/// Placeholder until the calculator feature lands (milestone M2).
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            context.l10n.appName,
            style: context.type.heroTitle.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
