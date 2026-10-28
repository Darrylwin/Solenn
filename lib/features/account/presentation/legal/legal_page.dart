import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/account/domain/legal/legal_document.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';
import 'package:solenn/features/account/domain/legal/legal_document_parser.dart';
import 'package:solenn/features/account/presentation/legal/legal_view.dart';
import 'package:solenn/l10n/l10n.dart';

/// A bundled legal text, loaded from `assets/legal` and shown by a
/// [LegalView].
///
/// The text comes from the asset bundle of the tree, so tests can replace it.
/// While it loads, or if it cannot be loaded, the page keeps its title and
/// its back button.
class LegalPage extends StatefulWidget {
  /// Creates the page for [kind].
  const LegalPage({required this.kind, super.key});

  /// Which text to show.
  final LegalDocumentKind kind;

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  Future<LegalDocument>? _document;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _document ??= _load(DefaultAssetBundle.of(context));
  }

  Future<LegalDocument> _load(AssetBundle bundle) async {
    final source = await bundle.loadString(
      'assets/legal/${widget.kind.name}.txt',
    );
    return const LegalDocumentParser().parse(source);
  }

  void _goBack() => unawaited(Navigator.of(context).maybePop());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (widget.kind) {
      LegalDocumentKind.terms => l10n.legalTermsTitle,
      LegalDocumentKind.privacy => l10n.legalPrivacyTitle,
    };

    return FutureBuilder<LegalDocument>(
      future: _document,
      builder: (context, snapshot) {
        final document = snapshot.data;
        if (document == null) {
          return SolennPageScaffold(
            title: title,
            backSemanticLabel: l10n.backSemantics,
            onBackPressed: _goBack,
            child: const SizedBox.shrink(),
          );
        }
        return LegalView(
          title: title,
          document: document,
          onBackPressed: _goBack,
        );
      },
    );
  }
}
