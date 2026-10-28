import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/app/account_content.dart';
import 'package:solenn/app/router/app_navigation.dart';
import 'package:solenn/core/services/app_info.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';
import 'package:solenn/features/account/presentation/account/account_view.dart';
import 'package:solenn/features/subscription/domain/pricing/pricing_catalog.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:solenn/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:solenn/l10n/l10n.dart';

/// The account screen, wired to the subscription flow and to the app info.
///
/// Restoring purchases needs no confirmation of its own: it unlocks the app,
/// the presenter then closes every screen above the home screen, and the home
/// screen shows its welcome banner.
class AccountScreen extends StatelessWidget {
  /// Creates the screen.
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final info = context.read<AppInfo>();
    final catalog = context.read<PricingCatalog>();
    final subscription = context.read<SubscriptionCubit>();
    final version = '${info.version} (${info.buildNumber})';

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        final plan = accountPlanFor(state, catalog, l10n);

        return AccountView(
          planName: plan.name,
          planDetail: plan.detail,
          planBadge: plan.badge,
          versionLabel: version,
          onBackPressed: () => unawaited(Navigator.of(context).maybePop()),
          onRestorePressed: subscription.restore,
          onTermsPressed: () => openLegal(context, LegalDocumentKind.terms),
          onPrivacyPressed: () => openLegal(context, LegalDocumentKind.privacy),
          onLicensesPressed: () => showLicensePage(
            context: context,
            applicationName: l10n.appName,
            applicationVersion: version,
          ),
        );
      },
    );
  }
}
