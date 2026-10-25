import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/input/repeat_operation.dart';

/// Where the input is in its life cycle.
enum InputPhase {
  /// The user is typing an expression.
  editing,

  /// An expression was evaluated and its result is displayed.
  evaluated,

  /// The last evaluation failed (division by zero, overflow).
  error,
}

/// The state of the calculator input.
///
/// While [InputPhase.editing], [tokens] is the committed prefix of the
/// expression (it always ends with an operator, or is empty) and [entry] is
/// the operand being typed. Once evaluated, [tokens] is the complete
/// expression and [result] is its displayed value.
class CalculatorInputState extends Equatable {
  /// Creates a state. The default is the initial, empty input.
  const CalculatorInputState({
    this.tokens = const [],
    this.entry,
    this.entryIsPercent = false,
    this.phase = InputPhase.editing,
    this.result,
    this.repeat,
  }) : assert(
         phase != InputPhase.evaluated || result != null,
         'An evaluated state needs a result.',
       );

  /// Committed tokens of the expression.
  final List<InputToken> tokens;

  /// Canonical text of the operand being typed, or `null` when there is none.
  final String? entry;

  /// Whether [entry] carries a percent sign.
  final bool entryIsPercent;

  /// Life-cycle phase.
  final InputPhase phase;

  /// Displayed result, set only when [phase] is [InputPhase.evaluated].
  final String? result;

  /// Operation repeated by a further `=`, once an expression was evaluated.
  final RepeatOperation? repeat;

  /// Whether the last evaluation failed.
  bool get isError => phase == InputPhase.error;

  /// The operator that was just typed and awaits its right operand, or `null`.
  ///
  /// The keypad draws the matching key in its selected state.
  ArithmeticOperator? get pendingOperator {
    if (phase != InputPhase.editing || entry != null) return null;
    if (tokens.lastOrNull case OperatorToken(:final value)) return value;
    return null;
  }

  /// The number shown on the main line of the display.
  ///
  /// It is the entry being typed, the operand before a pending operator, the
  /// result once evaluated, and zero otherwise.
  NumberToken get displayedNumber {
    switch (phase) {
      case InputPhase.evaluated:
        // The constructor guarantees a result in this phase.
        return NumberToken(result!);
      case InputPhase.error:
        return const NumberToken('0');
      case InputPhase.editing:
        break;
    }

    final entry = this.entry;
    if (entry != null) return NumberToken(entry, isPercent: entryIsPercent);
    if (tokens case [..., final NumberToken operand, OperatorToken()]) {
      return operand;
    }
    return const NumberToken('0');
  }

  @override
  List<Object?> get props => [
    tokens,
    entry,
    entryIsPercent,
    phase,
    result,
    repeat,
  ];
}
