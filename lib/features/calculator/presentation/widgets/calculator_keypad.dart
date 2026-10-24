import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/presentation/widgets/calculator_key_spec.dart';
import 'package:solenn/features/calculator/presentation/widgets/decimal_separator.dart';
import 'package:solenn/l10n/l10n.dart';

/// The 4 x 5 calculator keypad.
///
/// Keys are square cells of [keyDiameter]; the horizontal gap absorbs any
/// remaining width. Haptic feedback fires on pointer down.
class CalculatorKeypad extends StatelessWidget {
  /// Creates the keypad.
  const CalculatorKeypad({
    required this.keyDiameter,
    required this.onKeyPressed,
    this.selectedOperator,
    super.key,
  });

  /// Diameter of every key.
  final double keyDiameter;

  /// Called with the key that was tapped.
  final ValueChanged<CalculatorKey> onKeyPressed;

  /// The pending operator, drawn in its selected state.
  final CalculatorKey? selectedOperator;

  /// Key layout, top to bottom.
  static const List<List<CalculatorKey>> rows = [
    [
      CalculatorKey.backspace,
      CalculatorKey.clear,
      CalculatorKey.percent,
      CalculatorKey.divide,
    ],
    [
      CalculatorKey.seven,
      CalculatorKey.eight,
      CalculatorKey.nine,
      CalculatorKey.multiply,
    ],
    [
      CalculatorKey.four,
      CalculatorKey.five,
      CalculatorKey.six,
      CalculatorKey.subtract,
    ],
    [
      CalculatorKey.one,
      CalculatorKey.two,
      CalculatorKey.three,
      CalculatorKey.add,
    ],
    [
      CalculatorKey.toggleSign,
      CalculatorKey.zero,
      CalculatorKey.decimalSeparator,
      CalculatorKey.equals,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final gap = context.spacing.keyGap;
    final haptics = context.read<HapticsService>();
    final l10n = context.l10n;
    final decimalSeparator = decimalSeparatorFor(
      Localizations.localeOf(context).toString(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          if (index > 0) SizedBox(height: gap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final key in rows[index])
                SizedBox.square(
                  dimension: keyDiameter,
                  child: _buildKey(key, l10n, decimalSeparator, haptics),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildKey(
    CalculatorKey key,
    AppLocalizations l10n,
    String decimalSeparator,
    HapticsService haptics,
  ) {
    final spec = calculatorKeySpec(
      key,
      l10n: l10n,
      decimalSeparator: decimalSeparator,
    );
    return SolennKey(
      variant: spec.variant,
      label: spec.label,
      icon: spec.icon,
      semanticLabel: spec.semanticLabel,
      selected: key == selectedOperator,
      onPressStart: () => _feedback(haptics, key),
      onPressed: () => onKeyPressed(key),
    );
  }

  void _feedback(HapticsService haptics, CalculatorKey key) {
    if (key == CalculatorKey.equals) {
      haptics.medium();
    } else if (key.isOperator) {
      haptics.light();
    } else {
      haptics.selection();
    }
  }
}
