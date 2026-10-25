import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/history/history_item.dart';
import 'package:solenn/features/calculator/presentation/widgets/expression_spans.dart';
import 'package:solenn/l10n/l10n.dart';

const double _maxTextScale = 1.3;
const double _hairline = 1;

/// Content of the history sheet.
///
/// The caller presents it inside a `SolennSheetScaffold` through
/// `showSolennSheet`. Entries are listed in the order given (newest first).
/// A session history is short, so entries are built eagerly.
class HistoryView extends StatelessWidget {
  /// Creates the content.
  const HistoryView({
    required this.items,
    required this.onClearPressed,
    super.key,
  });

  /// Entries to show, newest first.
  final List<HistoryItem> items;

  /// Called when Clear is tapped. Clear is disabled while [items] is empty.
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.historyTitle,
                  style: context.type.titleLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
            SolennTextButton(
              label: l10n.historyClear,
              onPressed: items.isEmpty ? null : onClearPressed,
            ),
          ],
        ),
        SizedBox(height: spacing.xs),
        if (items.isEmpty)
          const _EmptyState()
        else
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const _Hairline(),
            _Entry(item: items[index]),
          ],
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: _maxTextScale);
    final expressionStyle = type.body.copyWith(
      fontWeight: FontWeight.w300,
      color: colors.textSecondary,
    );

    return Semantics(
      container: true,
      label: context.l10n.historyEntrySemantics(item.expression, item.result),
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text.rich(
              TextSpan(
                style: expressionStyle,
                children: highlightOperators(
                  item.expression,
                  operatorStyle: expressionStyle.copyWith(color: colors.accent),
                ),
              ),
              textAlign: TextAlign.end,
              textScaler: textScaler,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                item.result,
                maxLines: 1,
                textScaler: textScaler,
                style: type.keyDigit.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _hairline,
      child: ColoredBox(color: context.colors.outline),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.xxxl),
      child: Center(
        child: Text(
          context.l10n.historyEmpty,
          textAlign: TextAlign.center,
          style: context.type.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
