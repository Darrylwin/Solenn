import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/engine/expression_evaluator.dart';
import 'package:solenn/features/calculator/domain/engine/expression_parser.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_reducer.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/input/reduction_result.dart';

/// Characters understood by [CalculationSession.press].
const Map<String, CalculatorKey> calculatorKeysByCharacter = {
  '0': CalculatorKey.zero,
  '1': CalculatorKey.one,
  '2': CalculatorKey.two,
  '3': CalculatorKey.three,
  '4': CalculatorKey.four,
  '5': CalculatorKey.five,
  '6': CalculatorKey.six,
  '7': CalculatorKey.seven,
  '8': CalculatorKey.eight,
  '9': CalculatorKey.nine,
  '.': CalculatorKey.decimalSeparator,
  '~': CalculatorKey.toggleSign,
  '%': CalculatorKey.percent,
  'C': CalculatorKey.clear,
  'B': CalculatorKey.backspace,
  '+': CalculatorKey.add,
  '-': CalculatorKey.subtract,
  '*': CalculatorKey.multiply,
  '/': CalculatorKey.divide,
  '=': CalculatorKey.equals,
};

/// Plays key sequences through the real reducer, parser and evaluator.
///
/// Results are the truth: no sabotage is applied.
class CalculationSession {
  /// Creates a session on an empty input.
  CalculationSession();

  static const CalculatorInputReducer _reducer = CalculatorInputReducer();
  static const ExpressionParser _parser = ExpressionParser();
  static const ExpressionEvaluator _evaluator = ExpressionEvaluator();

  /// The current input state.
  CalculatorInputState state = const CalculatorInputState();

  /// Presses every key of [keys], in order.
  CalculationSession press(String keys) {
    for (final character in keys.split('')) {
      final key = calculatorKeysByCharacter[character];
      if (key == null) {
        throw ArgumentError.value(character, 'keys', 'Unknown key.');
      }
      _apply(key);
    }
    return this;
  }

  /// The main line of the display: `Error`, or the number with its percent
  /// sign when it has one.
  String get display {
    if (state.isError) return 'Error';
    final shown = state.displayedNumber;
    return shown.isPercent ? '${shown.text}%' : shown.text;
  }

  void _apply(CalculatorKey key) {
    switch (_reducer.reduce(state, key)) {
      case InputUpdated(state: final next):
        state = next;
      case EvaluationRequested(:final request):
        state = _evaluate(request);
    }
  }

  CalculatorInputState _evaluate(EvaluationRequest request) {
    final expression = _parser.parse(request.tokens);
    return switch (_evaluator.evaluate(expression)) {
      EvaluationSuccess(:final text) => _reducer.complete(
        request,
        result: text,
      ),
      EvaluationFailure() => _reducer.completeWithError(request),
    };
  }
}
