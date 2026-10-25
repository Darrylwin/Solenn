import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/design_system/components/solenn_sheet.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_row.dart';
import 'package:solenn/features/subscription/presentation/checkout/checkout_view.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_plan_option.dart';
import 'package:solenn/features/subscription/presentation/paywall/paywall_view.dart';
import 'package:solenn/l10n/l10n.dart';

void main() => runApp(const _Preview());

class _Preview extends StatefulWidget {
  const _Preview();

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  bool _ios = false;
  String _plan = 'annual';
  bool _processing = false;

  static const _plans = [
    PaywallPlanOption(
      id: 'annual',
      title: 'Annual',
      subtitle: r'7-day free trial · $3.33 / month',
      price: r'$39.99',
      anchorPrice: r'$59.88',
      badge: 'BEST VALUE · SAVE 33%',
      semanticLabel: 'Annual plan',
    ),
    PaywallPlanOption(
      id: 'monthly',
      title: 'Monthly',
      subtitle: 'Billed monthly · Cancel anytime',
      price: r'$4.99',
      semanticLabel: 'Monthly plan',
    ),
    PaywallPlanOption(
      id: 'enterprise',
      title: 'Enterprise',
      subtitle: 'Slightly less wrong results',
      price: r'$149.99',
      semanticLabel: 'Enterprise plan',
      dense: true,
    ),
  ];

  void _openCheckout(BuildContext context) {
    unawaited(
      showSolennSheet<void>(
        context: context,
        builder: (_) => SolennSheetScaffold(
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) => CheckoutView(
              planName: 'Annual subscription',
              rows: const [
                CheckoutRow(label: 'Free trial', value: '7 days'),
                CheckoutRow(label: 'Then', value: r'$39.99 / year'),
              ],
              dueToday: r'$0.00',
              processing: _processing,
              onCancelPressed: () => Navigator.of(sheetContext).pop(),
              onConfirmPressed: () async {
                setSheetState(() => _processing = true);
                await Future<void>.delayed(const Duration(milliseconds: 1200));
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                _processing = false;
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HapticsService>.value(
      value: const SystemHapticsService(),
      child: MaterialApp(
        theme: buildSolennTheme().copyWith(
          platform: _ios ? TargetPlatform.iOS : TargetPlatform.android,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Stack(
            children: [
              PaywallView(
                plans: _plans,
                selectedPlanId: _plan,
                ctaLabel: 'Start 7-day free trial',
                finePrint: r'Then $39.99 / year',
                socialProofCount: 12482,
                onPlanSelected: (id) => setState(() => _plan = id),
                onPurchasePressed: () => _openCheckout(context),
                onClosePressed: () {},
                onDeclinePressed: () {},
                onRestorePressed: () {},
                onTermsPressed: () {},
                onPrivacyPressed: () {},
                onSystemBackPressed: () {},
              ),
              Positioned(
                right: 12,
                bottom: 120,
                child: Switch(
                  value: _ios,
                  onChanged: (value) => setState(() => _ios = value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
