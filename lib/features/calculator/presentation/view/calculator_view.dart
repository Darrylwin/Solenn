import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_layout.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:solenn/l10n/l10n.dart';

/// The calculator screen.
///
/// A stateless consumer: it renders what it is given and reports key presses.
/// `headerCenter` and `banner` are slots filled by the `app` layer so that the
/// calculator never depends on other features.
class CalculatorView extends StatelessWidget {
  /// Creates the screen.
  const CalculatorView({
    required this.expression,
    required this.result,
    required this.onKeyPressed,
    this.caption,
    this.selectedOperator,
    this.headerCenter,
    this.banner,
    this.onHistoryPressed,
    this.onAccountPressed,
    this.onResultLongPress,
    this.debugLabel,
    this.revealKey,
    super.key,
  });

  /// The expression shown on the first line of the display.
  final String expression;

  /// The entry or result shown on the second line.
  final String result;

  /// Called with the key that was tapped.
  final ValueChanged<CalculatorKey> onKeyPressed;

  /// Optional caption at the top of the display.
  final String? caption;

  /// The pending operator, drawn in its selected state.
  final CalculatorKey? selectedOperator;

  /// Widget centered in the header row.
  final Widget? headerCenter;

  /// Widget shown between the header and the display.
  final Widget? banner;

  /// Called when the history button is tapped. `null` disables it.
  final VoidCallback? onHistoryPressed;

  /// Called when the account button is tapped. `null` disables it.
  final VoidCallback? onAccountPressed;

  /// Called on a long press of the display. `null` disables the gesture.
  final VoidCallback? onResultLongPress;

  /// Developer line shown over the display. `null` hides it.
  final String? debugLabel;

  /// Identifies the result on display; a new one is revealed with an
  /// animation. `null` while typing.
  final Object? revealKey;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final banner = this.banner;

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.only(
          left: spacing.screenMargin,
          right: spacing.screenMargin,
          top: spacing.sm,
          bottom: spacing.lg,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(
              constraints.maxWidth,
              spacing.maxContentWidth,
            );
            final diameter = calculatorKeyDiameter(
              spacing: spacing,
              width: width,
              height: constraints.maxHeight,
              hasBanner: banner != null,
            );

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      center: headerCenter,
                      onHistoryPressed: onHistoryPressed,
                      onAccountPressed: onAccountPressed,
                    ),
                    AnimatedSize(
                      duration: context.adaptiveDuration(context.motion.base),
                      curve: context.motion.standard,
                      alignment: Alignment.topCenter,
                      child: banner == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: EdgeInsets.only(top: spacing.lg),
                              child: banner,
                            ),
                    ),
                    SizedBox(height: spacing.xl),
                    Expanded(
                      // The card hugs the keypad; spare height collects above.
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: double.infinity,
                            maxHeight: calculatorMaxDisplayHeight,
                          ),
                          child: RepaintBoundary(
                            child: CalculatorDisplay(
                              expression: expression,
                              result: result,
                              caption: caption,
                              debugLabel: debugLabel,
                              revealKey: revealKey,
                              onLongPress: onResultLongPress,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.xxl),
                    CalculatorKeypad(
                      keyDiameter: diameter,
                      selectedOperator: selectedOperator,
                      onKeyPressed: onKeyPressed,
                    ),
                    SizedBox(height: spacing.md),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.center,
    required this.onHistoryPressed,
    required this.onAccountPressed,
  });

  final Widget? center;
  final VoidCallback? onHistoryPressed;
  final VoidCallback? onAccountPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        SolennIconButton(
          icon: Icons.history_rounded,
          semanticLabel: l10n.historyTooltip,
          onPressed: onHistoryPressed,
        ),
        Expanded(child: Center(child: center)),
        SolennIconButton(
          icon: Icons.person_outline_rounded,
          semanticLabel: l10n.accountTooltip,
          onPressed: onAccountPressed,
        ),
      ],
    );
  }
}
