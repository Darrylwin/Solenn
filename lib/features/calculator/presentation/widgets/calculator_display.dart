import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/widgets/expression_spans.dart';
import 'package:solenn/l10n/l10n.dart';

const double _maxTextScale = 1.3;
const double _captionIconSize = 14;

/// The two-line display card: expression above, result below.
///
/// The result shrinks to fit instead of wrapping or truncating. The
/// expression keeps its tail visible while it grows. A long press on the card
/// triggers [onLongPress]; screen readers get it as a "copy result" action.
/// A new result is revealed with a short fade and rise (see [revealKey]).
class CalculatorDisplay extends StatelessWidget {
  /// Creates the display.
  const CalculatorDisplay({
    required this.expression,
    required this.result,
    this.caption,
    this.debugLabel,
    this.revealKey,
    this.onLongPress,
    super.key,
  });

  /// The expression being typed or last evaluated.
  final String expression;

  /// The current entry or result, already formatted.
  final String result;

  /// Optional line shown at the top of the card.
  final String? caption;

  /// Developer line shown at the top-end of the card. `null` hides it.
  final String? debugLabel;

  /// Identifies the result on display. A change to a non-null value reveals
  /// the result with an animation; `null` (typing, an error) shows it at once.
  final Object? revealKey;

  /// Called on a long press of the card. `null` disables the gesture.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final spacing = context.spacing;
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: _maxTextScale);
    final caption = this.caption;
    final debugLabel = this.debugLabel;

    final expressionStyle = type.displayExpression.copyWith(
      color: colors.textSecondary,
    );

    return Semantics(
      liveRegion: true,
      label: context.l10n.calculatorResultSemantics(result),
      onLongPress: onLongPress,
      onLongPressHint: onLongPress == null
          ? null
          : context.l10n.calculatorCopyHint,
      child: ExcludeSemantics(
        child: GestureDetector(
          onLongPress: onLongPress,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(context.radii.displayCard),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: EdgeInsets.all(spacing.xxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text.rich(
                          TextSpan(
                            style: expressionStyle,
                            children: highlightOperators(
                              expression,
                              operatorStyle: expressionStyle.copyWith(
                                color: colors.accent,
                              ),
                            ),
                          ),
                          maxLines: 1,
                          softWrap: false,
                          textScaler: textScaler,
                        ),
                      ),
                      Flexible(
                        child: SolennReveal(
                          revealKey: revealKey,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              result,
                              maxLines: 1,
                              textScaler: textScaler,
                              style: type.displayResult.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (caption != null || debugLabel != null)
                  PositionedDirectional(
                    top: spacing.xl,
                    start: spacing.xxl,
                    end: spacing.xxl,
                    child: Row(
                      mainAxisAlignment: caption == null
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        if (caption != null)
                          Flexible(
                            flex: 3,
                            child: _Caption(
                              text: caption,
                              textScaler: textScaler,
                            ),
                          ),
                        if (debugLabel != null)
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: spacing.md,
                              ),
                              child: Text(
                                debugLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textScaler: textScaler,
                                style: type.label.copyWith(
                                  color: colors.accent,
                                ),
                              ),
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

class _Caption extends StatelessWidget {
  const _Caption({required this.text, required this.textScaler});

  final String text;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      children: [
        Icon(
          Icons.check_rounded,
          size: _captionIconSize,
          color: colors.accent,
        ),
        SizedBox(width: spacing.sm - spacing.xs / 2),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: textScaler,
            style: context.type.label.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
