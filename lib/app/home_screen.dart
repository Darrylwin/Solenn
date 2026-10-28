import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/app/paywall_presenter.dart';
import 'package:solenn/app/router/app_navigation.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_page.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/l10n/l10n.dart';

/// How long the welcome banner stays once the app is unlocked.
const Duration welcomeBannerDuration = Duration(seconds: 4);

/// Home of the application: the calculator, and the subscription flow around
/// it.
///
/// This is where the features meet. The calculator reports its calculations
/// and its account button, the subscription flow decides what to do with the
/// calculations, the account feature supplies the legal pages, and the slots
/// of the calculator receive the PLUS badge and the welcome banner.
class HomeScreen extends StatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _welcomeTimer;
  bool _welcomeVisible = false;

  @override
  void dispose() {
    _welcomeTimer?.cancel();
    super.dispose();
  }

  void _showWelcome() {
    _welcomeTimer?.cancel();
    setState(() => _welcomeVisible = true);
    _welcomeTimer = Timer(welcomeBannerDuration, () {
      if (mounted) setState(() => _welcomeVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.read<SubscriptionCubit>();
    final l10n = context.l10n;

    return BlocListener<SubscriptionCubit, SubscriptionState>(
      listenWhen: (previous, current) =>
          !previous.isUnlocked && current.isUnlocked,
      listener: (context, state) => _showWelcome(),
      child: PaywallPresenter(
        onTermsPressed: () => openLegal(context, LegalDocumentKind.terms),
        onPrivacyPressed: () => openLegal(context, LegalDocumentKind.privacy),
        child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
          buildWhen: (previous, current) =>
              previous.isUnlocked != current.isUnlocked,
          builder: (context, state) => CalculatorPage(
            onCalculationCommitted: subscription.calculationCommitted,
            onAccountPressed: () => openAccount(context),
            headerCenter: state.isUnlocked
                ? SolennChip(label: l10n.plusBadge)
                : null,
            banner: _welcomeVisible
                ? SolennBanner(
                    title: l10n.welcomeBannerTitle,
                    message: l10n.welcomeBannerMessage,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
