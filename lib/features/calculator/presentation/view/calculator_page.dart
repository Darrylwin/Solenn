import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/core/platform/platform.dart';
import 'package:solenn/features/calculator/domain/calculation/calculation_pipeline.dart';
import 'package:solenn/features/calculator/domain/formatting/calculator_display_formatter.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_engine.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:solenn/features/calculator/presentation/history/history_item.dart';
import 'package:solenn/features/calculator/presentation/history/history_view.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_debug_label.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_view.dart';
import 'package:solenn/features/calculator/presentation/widgets/locale_number_symbols.dart';
import 'package:solenn/l10n/l10n.dart';

/// How long the "Copied" confirmation replaces the caption of the display.
const Duration calculatorCopiedDuration = Duration(milliseconds: 1500);

/// The calculator: creates its Cubit and turns its state into a screen.
///
/// The sabotage engine comes from the tree, where `app` provides the one of
/// the launch. `headerCenter` and `banner` are slots for the `app` layer.
class CalculatorPage extends StatelessWidget {
  /// Creates the page.
  const CalculatorPage({this.headerCenter, this.banner, super.key});

  /// Widget centered in the header row.
  final Widget? headerCenter;

  /// Widget shown between the header and the display.
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorCubit(
        pipeline: CalculationPipeline(
          sabotageEngine: context.read<SabotageEngine>(),
        ),
      ),
      child: _CalculatorScreen(headerCenter: headerCenter, banner: banner),
    );
  }
}

class _CalculatorScreen extends StatefulWidget {
  const _CalculatorScreen({required this.headerCenter, required this.banner});

  final Widget? headerCenter;
  final Widget? banner;

  @override
  State<_CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<_CalculatorScreen> {
  late CalculatorDisplayFormatter _formatter;
  Timer? _copiedTimer;
  bool _copied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Symbols are read once per locale, not on every key press.
    _formatter = CalculatorDisplayFormatter(
      numberSymbolsFor(Localizations.localeOf(context).toString()),
    );
  }

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    final l10n = context.l10n;

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (previous, current) => previous.input != current.input,
      builder: (context, state) {
        final input = state.input;
        final display = _formatter.format(
          input,
          errorLabel: l10n.calculatorError,
        );

        return CalculatorView(
          expression: display.expression,
          result: display.result,
          caption: _caption(input, l10n),
          selectedOperator: input.pendingOperator?.key,
          headerCenter: widget.headerCenter,
          banner: widget.banner,
          debugLabel: calculatorDebugLabel(state, _formatter),
          onKeyPressed: cubit.pressKey,
          // There is nothing worth copying from an error.
          onResultLongPress: input.isError ? null : () => _copy(display.result),
          onHistoryPressed: () => _openHistory(cubit),
        );
      },
    );
  }

  String? _caption(CalculatorInputState input, AppLocalizations l10n) {
    if (_copied) return l10n.calculatorCopied;
    return input.phase == InputPhase.evaluated ? l10n.calculatorCaption : null;
  }

  void _copy(String text) {
    unawaited(context.read<ClipboardService>().copy(text));
    context.read<HapticsService>().medium();

    _copiedTimer?.cancel();
    setState(() => _copied = true);
    _copiedTimer = Timer(calculatorCopiedDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _openHistory(CalculatorCubit cubit) async {
    final formatter = _formatter;

    await showSolennSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: SolennSheetScaffold(
          child: BlocBuilder<CalculatorCubit, CalculatorState>(
            buildWhen: (previous, current) =>
                previous.history != current.history,
            builder: (context, state) => HistoryView(
              items: [
                for (final entry in state.history)
                  HistoryItem(
                    expression: formatter.formatExpression(entry.tokens),
                    result: formatter.formatNumber(entry.result),
                  ),
              ],
              onClearPressed: cubit.clearHistory,
            ),
          ),
        ),
      ),
    );
  }
}
