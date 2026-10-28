import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/features/calculator/domain/calculation/calculation_outcome.dart';
import 'package:solenn/features/calculator/domain/calculation/calculation_pipeline.dart';
import 'package:solenn/features/calculator/domain/history/history_entry.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_reducer.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/input/reduction_result.dart';
import 'package:solenn/features/calculator/presentation/cubit/calculator_state.dart';

/// Most calculations kept in the history. Older ones are dropped.
const int maxHistoryEntries = 100;

/// Runs the calculator: keys in, display state out.
///
/// All rules live in the domain. This class only relays key presses to the
/// reducer, asks the pipeline for results when the reducer requests them, and
/// keeps the session history.
class CalculatorCubit extends Cubit<CalculatorState> {
  /// Creates a calculator that computes with [pipeline].
  CalculatorCubit({
    required CalculationPipeline pipeline,
    CalculatorInputReducer reducer = const CalculatorInputReducer(),
  }) : _pipeline = pipeline,
       _reducer = reducer,
       super(const CalculatorState());

  final CalculationPipeline _pipeline;
  final CalculatorInputReducer _reducer;

  /// Applies a press of [key].
  void pressKey(CalculatorKey key) {
    switch (_reducer.reduce(state.input, key)) {
      case InputUpdated(state: final input):
        // Ignoring a key that changes nothing avoids a useless rebuild.
        if (input != state.input) emit(state.copyWith(input: input));
      case EvaluationRequested(:final request):
        _evaluate(request);
    }
  }

  /// Erases the history. The calculation counter is kept: the lies keep
  /// escalating.
  void clearHistory() {
    if (state.history.isEmpty) return;
    emit(state.copyWith(history: const []));
  }

  void _evaluate(EvaluationRequest request) {
    final index = state.committedCount + 1;

    switch (_pipeline.calculate(request, calculationIndex: index)) {
      case CalculationSucceeded(:final result, :final sabotage):
        final entry = HistoryEntry(tokens: request.tokens, result: result);
        emit(
          CalculatorState(
            input: _reducer.complete(request, result: result),
            history: [
              entry,
              ...state.history,
            ].take(maxHistoryEntries).toList(growable: false),
            committedCount: index,
            lastOutcome: sabotage,
          ),
        );
      case CalculationFailed():
        emit(state.copyWith(input: _reducer.completeWithError(request)));
    }
  }
}
