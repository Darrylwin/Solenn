import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/press_feedback.dart';
import 'package:solenn/core/design_system/components/solenn_chip.dart';
import 'package:solenn/core/design_system/components/solenn_pressable.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

const double _radioSize = 22;
const double _radioDotSize = 10;
const double _radioBorderWidth = 1.5;
const double _borderWidth = 1;
const double _selectedBorderWidth = 1.5;
const double _badgeOverlap = 10;
const double _maxPriceShare = 0.45;

// Beyond this text scale the price moves under the title: a side-by-side
// layout would leave the title too narrow to read.
const double _stackedTextScale = 1.3;
const double _scaleProbeSize = 16;

/// A selectable subscription plan card, used as a radio in a group.
///
/// The card knows nothing about plans or money: callers pass display strings
/// and the complete spoken description in [semanticLabel]. With large text it
/// stacks the price under the title instead of squeezing both on one line.
/// Its selection animation is dropped when the user asked for less motion.
class SolennPlanCard extends StatelessWidget {
  /// Creates a plan card.
  const SolennPlanCard({
    required this.title,
    required this.price,
    required this.selected,
    required this.semanticLabel,
    required this.onPressed,
    this.subtitle,
    this.anchorPrice,
    this.badge,
    this.dense = false,
    this.onPressStart,
    super.key,
  });

  /// Plan name.
  final String title;

  /// Price shown on the trailing edge (under the title with large text).
  final String price;

  /// Whether this plan is the selected one of its group.
  final bool selected;

  /// Complete spoken description of the card, badge and anchor included.
  final String semanticLabel;

  /// Called when the card is tapped.
  final VoidCallback? onPressed;

  /// Secondary line below the title.
  final String? subtitle;

  /// Struck-through reference price below [price].
  final String? anchorPrice;

  /// Uppercase badge overlapping the top edge.
  final String? badge;

  /// Compact variant for secondary plans.
  final bool dense;

  /// Called as soon as a pointer touches the card.
  final VoidCallback? onPressStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final type = context.type;
    final motion = context.motion;
    final duration = context.adaptiveDuration(motion.fast);
    final radius = BorderRadius.circular(context.radii.planCard);
    final shape = RoundedRectangleBorder(borderRadius: radius);

    final textScale =
        MediaQuery.textScalerOf(context).scale(_scaleProbeSize) /
        _scaleProbeSize;
    final stacked = textScale > _stackedTextScale;

    final titleStyle =
        (dense
                ? type.body.copyWith(fontWeight: FontWeight.w600)
                : type.titleMedium)
            .copyWith(color: colors.textPrimary);
    final priceStyle = (dense ? type.titleMedium : type.price).copyWith(
      color: colors.textPrimary,
    );
    final secondaryStyle = type.bodySmall.copyWith(color: colors.textSecondary);

    final subtitle = this.subtitle;
    final anchorPrice = this.anchorPrice;
    final badge = this.badge;

    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        if (subtitle != null) Text(subtitle, style: secondaryStyle),
      ],
    );

    final priceBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: stacked
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(price, style: priceStyle),
        if (anchorPrice != null)
          Text(
            anchorPrice,
            style: secondaryStyle.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );

    final card = AnimatedContainer(
      duration: duration,
      curve: motion.standard,
      foregroundDecoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? colors.accent : colors.outline,
            width: selected ? _selectedBorderWidth : _borderWidth,
          ),
        ),
      ),
      child: SolennPressable(
        shape: shape,
        decoration: ShapeDecoration(color: colors.surface, shape: shape),
        overlayColor: colors.textPrimary.withValues(
          alpha: solennPressOverlayAlpha,
        ),
        onPressed: onPressed,
        onPressStart: onPressStart,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xl,
            vertical: dense ? spacing.md : spacing.lg,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                _Radio(selected: selected),
                SizedBox(width: spacing.lg),
                Expanded(
                  child: stacked
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleBlock,
                            SizedBox(height: spacing.sm),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: priceBlock,
                            ),
                          ],
                        )
                      : titleBlock,
                ),
                if (!stacked) ...[
                  SizedBox(width: spacing.md),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * _maxPriceShare,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: priceBlock,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          if (badge != null)
            PositionedDirectional(
              top: -_badgeOverlap,
              end: spacing.xl,
              child: SolennChip(label: badge),
            ),
        ],
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final duration = context.adaptiveDuration(motion.fast);
    final dot = selected ? _radioDotSize : 0.0;

    return AnimatedContainer(
      duration: duration,
      curve: motion.standard,
      width: _radioSize,
      height: _radioSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.accent : colors.iconMuted,
          width: _radioBorderWidth,
        ),
      ),
      child: AnimatedContainer(
        duration: duration,
        curve: motion.standard,
        width: dot,
        height: dot,
        decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
      ),
    );
  }
}
