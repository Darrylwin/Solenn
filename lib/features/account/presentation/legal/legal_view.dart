import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/account/domain/legal/legal_block.dart';
import 'package:solenn/features/account/domain/legal/legal_document.dart';
import 'package:solenn/l10n/l10n.dart';

const double _fadeHeight = 96;

/// A legal page: a back button, a title and a scrolling document.
///
/// The text fades out at the bottom edge to hint at more content; the scroll
/// area keeps matching padding so the last line is never hidden.
class LegalView extends StatelessWidget {
  /// Creates the page.
  const LegalView({
    required this.title,
    required this.document,
    required this.onBackPressed,
    super.key,
  });

  /// Page title, for example `Terms of Service`.
  final String title;

  /// The document to display.
  final LegalDocument document;

  /// Called when the back button is tapped.
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final background = context.colors.background;
    final blocks = document.blocks;

    return SolennPageScaffold(
      title: title,
      backSemanticLabel: context.l10n.backSemantics,
      onBackPressed: onBackPressed,
      child: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: _fadeHeight),
            itemCount: blocks.length,
            itemBuilder: (context, index) =>
                _Block(block: blocks[index], isFirst: index == 0),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _fadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [background.withValues(alpha: 0), background],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block, required this.isFirst});

  final LegalBlock block;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final type = context.type;

    return switch (block) {
      LegalHeading(:final text) => Semantics(
        header: true,
        child: Padding(
          padding: EdgeInsets.only(
            top: isFirst ? 0 : spacing.xxl,
            bottom: spacing.sm,
          ),
          child: Text(
            text,
            style: type.titleMedium.copyWith(color: colors.textPrimary),
          ),
        ),
      ),
      LegalParagraph(:final text) => Padding(
        padding: EdgeInsets.only(bottom: spacing.md),
        child: Text(
          text,
          style: type.body.copyWith(color: colors.textSecondary),
        ),
      ),
    };
  }
}
