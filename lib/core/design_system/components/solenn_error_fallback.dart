import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/solenn_brand_mark.dart';
import 'package:solenn/core/design_system/theme/solenn_theme.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors.dart';
import 'package:solenn/core/design_system/tokens/solenn_spacing.dart';
import 'package:solenn/core/design_system/tokens/solenn_typography.dart';

const double _markSize = 56;
const double _messageMaxWidth = 300;

/// The branded, non-technical screen that replaces a widget that failed to
/// build in a release build.
///
/// It is drawn where the failure happened, so it cannot count on any
/// ancestor: it brings its own directionality, theme and tokens. It scales
/// down to fit a small slot (a key, a row) instead of overflowing.
class SolennErrorFallback extends StatelessWidget {
  /// Creates the fallback.
  const SolennErrorFallback({
    required this.initial,
    required this.title,
    required this.message,
    this.textDirection = TextDirection.ltr,
    super.key,
  });

  /// Letter drawn inside the brand mark.
  final String initial;

  /// What happened, in a few words.
  final String title;

  /// What the user can do about it.
  final String message;

  /// Reading direction of [title] and [message].
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    const colors = SolennColors.dark;
    const type = SolennTypography.standard;
    const spacing = SolennSpacing.standard;

    return Directionality(
      textDirection: textDirection,
      child: Theme(
        data: buildSolennTheme(),
        child: Material(
          type: MaterialType.transparency,
          child: Semantics(
            container: true,
            label: '$title. $message',
            child: ExcludeSemantics(
              child: ColoredBox(
                color: colors.background,
                child: FittedBox(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.screenMargin),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SolennBrandMark(
                          initial: initial,
                          size: _markSize,
                          shape: SolennBrandMarkShape.squircle,
                        ),
                        SizedBox(height: spacing.xl),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: type.titleLarge.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _messageMaxWidth,
                          ),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: type.body.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
