import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/history/history_entry.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';

/// State of the calculator.
///
/// It holds domain data only, never text: formatting depends on the locale and
/// belongs to the view.
class CalculatorState extends Equatable {
  /// Creates a state. The default is a calculator that was just opened.
  const CalculatorState({
    this.input = const CalculatorInputState(),
    this.history = const [],
    this.committedCount = 0,
  });

  /// The keypad input.
  final CalculatorInputState input;

  /// Calculations of this launch, newest first.
  final List<HistoryEntry> history;

  /// Number of successful calculations of this launch.
  ///
  /// It drives the escalation of the lies, and tells the rest of the app that
  /// a calculation just completed. Failures and history clearing do not change
  /// it.
  final int committedCount;

  /// A copy with the given values replaced.
  CalculatorState copyWith({
    CalculatorInputState? input,
    List<HistoryEntry>? history,
    int? committedCount,
  }) {
    return CalculatorState(
      input: input ?? this.input,
      history: history ?? this.history,
      committedCount: committedCount ?? this.committedCount,
    );
  }

  @override
  List<Object> get props => [input, history, committedCount];
}
