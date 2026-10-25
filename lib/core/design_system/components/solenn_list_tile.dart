import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/press_feedback.dart';
import 'package:solenn/core/design_system/components/solenn_pressable.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

const double _minTileHeight = 56;
const double _chevronSize = 20;

/// A row of a [SolennListGroup]: a title, an optional trailing value and, when
/// it can be tapped, a chevron.
///
/// Without [onPressed] the tile is informative: no feedback, no chevron.
class SolennListTile extends StatelessWidget {
  /// Creates a tile.
  const SolennListTile({
    required this.title,
    this.value,
    this.onPressed,
    super.key,
  });

  /// Main label.
  final String title;

  /// Trailing value, for example a version number.
  final String? value;

  /// Called when the tile is tapped. `null` makes the tile informative.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final type = context.type;
    final value = this.value;
    final tappable = onPressed != null;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minTileHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xl,
          vertical: spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: type.titleMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (value != null) ...[
              SizedBox(width: spacing.md),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: type.body.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
            if (tappable) ...[
              SizedBox(width: spacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: _chevronSize,
                color: colors.iconMuted,
              ),
            ],
          ],
        ),
      ),
    );

    if (!tappable) return MergeSemantics(child: content);

    return Semantics(
      button: true,
      label: title,
      onTap: onPressed,
      excludeSemantics: true,
      child: SolennPressable(
        shape: const RoundedRectangleBorder(),
        overlayColor: colors.textPrimary.withValues(
          alpha: solennPressOverlayAlpha,
        ),
        onPressed: onPressed,
        child: content,
      ),
    );
  }
}
