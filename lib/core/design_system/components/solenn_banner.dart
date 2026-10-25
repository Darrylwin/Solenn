import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

const double _badgeSize = 32;
const double _badgeIconSize = 18;

/// An informational banner with a check mark, a title and a message.
///
/// It is announced to screen readers when it appears.
class SolennBanner extends StatelessWidget {
  /// Creates a banner.
  const SolennBanner({required this.title, required this.message, super.key});

  /// Bold first line.
  final String title;

  /// Secondary second line.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final type = context.type;

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $message',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.radii.banner),
              side: BorderSide(color: colors.accentMuted),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: _badgeSize,
                    child: Icon(
                      Icons.check_rounded,
                      size: _badgeIconSize,
                      color: colors.onAccent,
                    ),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: type.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        message,
                        style: type.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
