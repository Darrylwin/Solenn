import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/presentation/widgets/expression_spans.dart';
import 'package:solenn/l10n/l10n.dart';

const double _maxTextScale = 1.3;
const double _captionIconSize = 14;

/// The two-line display card: expression above, result below.
///
/// The result shrinks to fit instead of wrapping or truncating. The
/// expression keeps its tail visible while it grows.
class CalculatorDisplay extends StatelessWidget {
  /// Creates the display.
  const CalculatorDisplay({
    required this.expression,
    required this.result,
    this.caption,
    super.key,
  });

  /// The expression being typed or last evaluated.
  final String expression;

  /// The current entry or result, already formatted.
  final String result;

  /// Optional line shown at the top of the card.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final spacing = context.spacing;
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: _maxTextScale);
    final caption = this.caption;

    final expressionStyle = type.displayExpression.copyWith(
      color: colors.textSecondary,
    );

    return Semantics(
      liveRegion: true,
      label: context.l10n.calculatorResultSemantics(result),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(context.radii.displayCard),
          ),
          child: Stack(
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
                  ],
                ),
              ),
              if (caption != null)
                PositionedDirectional(
                  top: spacing.xl,
                  start: spacing.xxl,
                  end: spacing.xxl,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: _captionIconSize,
                        color: colors.accent,
                      ),
                      SizedBox(width: spacing.sm - spacing.xs / 2),
                      Flexible(
                        child: Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: textScaler,
                          style: type.label.copyWith(
                            color: colors.textSecondary,
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
    );
  }
}
