import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';

void main() => runApp(const _Preview());

class _Preview extends StatefulWidget {
  const _Preview();

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  bool _ios = false;
  int _plan = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildSolennTheme().copyWith(
        platform: _ios ? TargetPlatform.iOS : TargetPlatform.android,
      ),
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SwitchListTile(
                title: const Text('iOS style'),
                value: _ios,
                onChanged: (value) => setState(() => _ios = value),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  SolennChip(label: 'PLUS'),
                  SizedBox(width: 12),
                  SolennChip(label: 'BEST VALUE · SAVE 33%'),
                ],
              ),
              const SizedBox(height: 24),
              const SolennBanner(
                title: 'Welcome to Solenn Plus',
                message: 'Your plan is active. Calculate without limits.',
              ),
              const SizedBox(height: 28),
              SolennPlanCard(
                title: 'Annual',
                subtitle: r'7-day free trial · $3.33 / month',
                price: r'$39.99',
                anchorPrice: r'$59.88',
                badge: 'BEST VALUE · SAVE 33%',
                selected: _plan == 0,
                semanticLabel: 'Annual plan',
                onPressed: () => setState(() => _plan = 0),
              ),
              const SizedBox(height: 12),
              SolennPlanCard(
                title: 'Monthly',
                subtitle: 'Billed monthly · Cancel anytime',
                price: r'$4.99',
                selected: _plan == 1,
                semanticLabel: 'Monthly plan',
                onPressed: () => setState(() => _plan = 1),
              ),
              const SizedBox(height: 12),
              SolennPlanCard(
                dense: true,
                title: 'Enterprise',
                subtitle: 'Slightly less wrong results',
                price: r'$149.99',
                selected: _plan == 2,
                semanticLabel: 'Enterprise plan',
                onPressed: () => setState(() => _plan = 2),
              ),
              const SizedBox(height: 28),
              SolennPrimaryButton(
                label: 'Start 7-day free trial',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              SolennPrimaryButton(
                label: 'Start 7-day free trial',
                loading: true,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              Center(
                child: SolennTextButton(
                  label: 'I prefer inaccurate results',
                  onPressed: () {},
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final label in ['Restore', 'Terms', 'Privacy'])
                    SolennTextButton(
                      label: label,
                      size: SolennTextButtonSize.small,
                      onPressed: () {},
                    ),
                ],
              ),
              Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSolennSheet<void>(
                    context: context,
                    builder: (_) => SolennSheetScaffold(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Solenn Plus',
                            style: context.type.titleLarge.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SolennPrimaryButton(
                            label: 'Confirm subscription',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Open sheet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
