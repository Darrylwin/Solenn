import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/features/account/domain/legal/legal_document_parser.dart';
import 'package:solenn/features/account/presentation/account/account_view.dart';
import 'package:solenn/features/account/presentation/legal/legal_view.dart';
import 'package:solenn/features/calculator/presentation/history/history_item.dart';
import 'package:solenn/features/calculator/presentation/history/history_view.dart';
import 'package:solenn/l10n/l10n.dart';

void main() => runApp(const _Preview());

class _Preview extends StatefulWidget {
  const _Preview();

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  bool _ios = false;
  List<HistoryItem> _items = const [
    HistoryItem(expression: '36×4', result: '414'),
    HistoryItem(expression: '9−3', result: '12'),
    HistoryItem(expression: '7.3+1.2', result: '10'),
    HistoryItem(expression: '24,000+220', result: '24,820'),
  ];

  Future<void> _openLegal(
    BuildContext context,
    String name,
    String title,
  ) async {
    final source = await rootBundle.loadString('assets/legal/$name.txt');
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) => LegalView(
          title: title,
          document: const LegalDocumentParser().parse(source),
          onBackPressed: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
  }

  Future<void> _openAccount(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) => AccountView(
          planName: 'Solenn Plus',
          planDetail: 'Annual · 7-day free trial',
          planBadge: 'PLUS',
          versionLabel: '0.1.0 (1)',
          onBackPressed: () => Navigator.of(pageContext).pop(),
          onRestorePressed: () {},
          onTermsPressed: () =>
              _openLegal(pageContext, 'terms', 'Terms of Service'),
          onPrivacyPressed: () =>
              _openLegal(pageContext, 'privacy', 'Privacy Policy'),
          onLicensesPressed: () => showLicensePage(context: pageContext),
        ),
      ),
    );
  }

  Future<void> _openHistory(BuildContext context) async {
    await showSolennSheet<void>(
      context: context,
      builder: (_) => SolennSheetScaffold(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => HistoryView(
            items: _items,
            onClearPressed: () {
              setState(() => _items = const []);
              setSheetState(() {});
            },
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
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      title: const Text('iOS style'),
                      value: _ios,
                      onChanged: (value) => setState(() => _ios = value),
                    ),
                    const SizedBox(height: 24),
                    SolennPrimaryButton(
                      label: 'History sheet',
                      onPressed: () => _openHistory(context),
                    ),
                    const SizedBox(height: 12),
                    SolennPrimaryButton(
                      label: 'Account',
                      onPressed: () => _openAccount(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
