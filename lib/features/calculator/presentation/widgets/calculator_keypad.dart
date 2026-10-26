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
/// remaining width. Haptic feedback fires on pointer down. The keys are built
/// once and reused until the diameter, the pending operator, the callback or
/// the theme or locale change, so typing never rebuilds them.
class CalculatorKeypad extends StatefulWidget {
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
  State<CalculatorKeypad> createState() => _CalculatorKeypadState();
}

class _CalculatorKeypadState extends State<CalculatorKeypad> {
  // The same instance is returned until an input changes, so the framework
  // skips the whole subtree.
  _KeypadGrid? _grid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _grid = null;
  }

  @override
  void didUpdateWidget(CalculatorKeypad oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        oldWidget.keyDiameter != widget.keyDiameter ||
        oldWidget.selectedOperator != widget.selectedOperator ||
        oldWidget.onKeyPressed != widget.onKeyPressed;
    if (changed) _grid = null;
  }

  @override
  Widget build(BuildContext context) {
    return _grid ??= _KeypadGrid(
      keyDiameter: widget.keyDiameter,
      gap: context.spacing.keyGap,
      selectedOperator: widget.selectedOperator,
      onKeyPressed: widget.onKeyPressed,
      haptics: context.read<HapticsService>(),
      l10n: context.l10n,
      decimalSeparator: decimalSeparatorFor(
        Localizations.localeOf(context).toString(),
      ),
    );
  }
}

class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({
    required this.keyDiameter,
    required this.gap,
    required this.selectedOperator,
    required this.onKeyPressed,
    required this.haptics,
    required this.l10n,
    required this.decimalSeparator,
  });

  final double keyDiameter;
  final double gap;
  final CalculatorKey? selectedOperator;
  final ValueChanged<CalculatorKey> onKeyPressed;
  final HapticsService haptics;
  final AppLocalizations l10n;
  final String decimalSeparator;

  @override
  Widget build(BuildContext context) {
    const rows = CalculatorKeypad.rows;

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
                  child: _KeypadKey(
                    calculatorKey: key,
                    selected: key == selectedOperator,
                    l10n: l10n,
                    decimalSeparator: decimalSeparator,
                    haptics: haptics,
                    onKeyPressed: onKeyPressed,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.calculatorKey,
    required this.selected,
    required this.l10n,
    required this.decimalSeparator,
    required this.haptics,
    required this.onKeyPressed,
  });

  final CalculatorKey calculatorKey;
  final bool selected;
  final AppLocalizations l10n;
  final String decimalSeparator;
  final HapticsService haptics;
  final ValueChanged<CalculatorKey> onKeyPressed;

  @override
  Widget build(BuildContext context) {
    final spec = calculatorKeySpec(
      calculatorKey,
      l10n: l10n,
      decimalSeparator: decimalSeparator,
    );

    return SolennKey(
      variant: spec.variant,
      label: spec.label,
      icon: spec.icon,
      semanticLabel: spec.semanticLabel,
      selected: selected,
      onPressStart: _feedback,
      onPressed: () => onKeyPressed(calculatorKey),
    );
  }

  void _feedback() {
    if (calculatorKey == CalculatorKey.equals) {
      haptics.medium();
    } else if (calculatorKey.isOperator) {
      haptics.light();
    } else {
      haptics.selection();
    }
  }
}
