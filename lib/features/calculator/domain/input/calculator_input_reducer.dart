import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/input/reduction_result.dart';

/// Maximum number of digits of one operand (specification section 7.2).
const int maxEntryDigits = 9;

const String _negativeSign = '-';
const String _decimalPoint = '.';
const String _zero = '0';

final RegExp _nonDigits = RegExp('[^0-9]');

/// The pure state machine behind the keypad.
///
/// It applies the input rules of the specification (section 7.2) and never
/// computes anything. Pressing `=` returns an [EvaluationRequested]; the
/// caller evaluates it and reports the outcome through [complete] or
/// [completeWithError].
class CalculatorInputReducer {
  /// Creates a reducer. It holds no state.
  const CalculatorInputReducer();

  /// Applies [key] to [state].
  ReductionResult reduce(CalculatorInputState state, CalculatorKey key) {
    if (key.digit case final digit?) {
      return InputUpdated(_enterDigit(state, digit));
    }
    if (key.arithmeticOperator case final operation?) {
      return InputUpdated(_applyOperator(state, operation));
    }
    return switch (key) {
      CalculatorKey.decimalSeparator => InputUpdated(_enterDecimalPoint(state)),
      CalculatorKey.toggleSign => InputUpdated(_toggleSign(state)),
      CalculatorKey.percent => InputUpdated(_applyPercent(state)),
      CalculatorKey.clear => const InputUpdated(CalculatorInputState()),
      CalculatorKey.backspace => InputUpdated(_backspace(state)),
      CalculatorKey.equals => _equals(state),
      // Digits and operators are handled above.
      _ => InputUpdated(state),
    };
  }

  /// The state after [request] was evaluated and displayed as [result].
  ///
  /// [result] is a canonical decimal (see `NumberToken`). It is the value the
  /// user sees, which later chaining continues from.
  CalculatorInputState complete(
    EvaluationRequest request, {
    required String result,
  }) {
    return CalculatorInputState(
      tokens: request.tokens,
      phase: InputPhase.evaluated,
      result: result,
      repeat: request.repeatOperation,
    );
  }

  /// The state after the evaluation of [request] failed.
  CalculatorInputState completeWithError(EvaluationRequest request) {
    return CalculatorInputState(
      tokens: request.tokens,
      phase: InputPhase.error,
    );
  }

  CalculatorInputState _enterDigit(CalculatorInputState state, int digit) {
    // A digit after a result or an error starts a new expression.
    if (state.phase != InputPhase.editing) {
      return CalculatorInputState(entry: '$digit');
    }
    // A percent sign closes the operand.
    if (state.entryIsPercent) return state;

    return _withEntry(state, _appendDigit(state.entry, digit));
  }

  String _appendDigit(String? entry, int digit) {
    if (entry == null) return '$digit';

    final sign = entry.startsWith(_negativeSign) ? _negativeSign : '';
    final body = entry.substring(sign.length);
    // A lone zero is replaced, not extended: 0 then 5 reads 5, not 05.
    if (body == _zero) return '$sign$digit';
    if (_digitCount(entry) >= maxEntryDigits) return entry;
    return '$entry$digit';
  }

  CalculatorInputState _enterDecimalPoint(CalculatorInputState state) {
    if (state.phase != InputPhase.editing) {
      return const CalculatorInputState(entry: '0$_decimalPoint');
    }
    if (state.entryIsPercent) return state;

    final entry = state.entry;
    if (entry == null) return _withEntry(state, '0$_decimalPoint');
    if (entry.contains(_decimalPoint)) return state;
    return _withEntry(state, '$entry$_decimalPoint');
  }

  CalculatorInputState _applyOperator(
    CalculatorInputState state,
    ArithmeticOperator operation,
  ) {
    switch (state.phase) {
      case InputPhase.error:
        return state;
      case InputPhase.evaluated:
        // Chaining continues from the displayed value, so that the lie
        // compounds consistently with what the user sees.
        return CalculatorInputState(
          tokens: [NumberToken(state.result!), OperatorToken(operation)],
        );
      case InputPhase.editing:
        break;
    }

    final entry = state.entry;
    if (entry != null) {
      return CalculatorInputState(
        tokens: [
          ...state.tokens,
          _commit(entry, isPercent: state.entryIsPercent),
          OperatorToken(operation),
        ],
      );
    }
    if (state.tokens.isEmpty) {
      return CalculatorInputState(
        tokens: [const NumberToken(_zero), OperatorToken(operation)],
      );
    }
    // An operator after an operator replaces it.
    return CalculatorInputState(
      tokens: [
        ...state.tokens.sublist(0, state.tokens.length - 1),
        OperatorToken(operation),
      ],
    );
  }

  CalculatorInputState _toggleSign(CalculatorInputState state) {
    switch (state.phase) {
      case InputPhase.error:
        return state;
      case InputPhase.evaluated:
        return CalculatorInputState(entry: _negate(state.result!));
      case InputPhase.editing:
        break;
    }

    return CalculatorInputState(
      tokens: state.tokens,
      entry: _negate(state.entry ?? _zero),
      entryIsPercent: state.entryIsPercent,
    );
  }

  CalculatorInputState _applyPercent(CalculatorInputState state) {
    switch (state.phase) {
      case InputPhase.error:
        return state;
      case InputPhase.evaluated:
        return CalculatorInputState(entry: state.result, entryIsPercent: true);
      case InputPhase.editing:
        break;
    }

    // The percent sign is only a marker here. Its value depends on the
    // operators around it and is resolved by the evaluator.
    final entry = state.entry;
    if (entry == null || state.entryIsPercent) return state;
    return CalculatorInputState(
      tokens: state.tokens,
      entry: entry,
      entryIsPercent: true,
    );
  }

  CalculatorInputState _backspace(CalculatorInputState state) {
    if (state.phase != InputPhase.editing) return state;

    final entry = state.entry;
    if (entry == null) return state;
    if (state.entryIsPercent) return _withEntry(state, entry);

    final shortened = entry.substring(0, entry.length - 1);
    final emptied = shortened.isEmpty || shortened == _negativeSign;
    return _withEntry(state, emptied ? null : shortened);
  }

  ReductionResult _equals(CalculatorInputState state) {
    switch (state.phase) {
      case InputPhase.error:
        return InputUpdated(state);
      case InputPhase.evaluated:
        final repeat = state.repeat;
        if (repeat == null) return InputUpdated(state);
        return EvaluationRequested(
          EvaluationRequest(
            tokens: [
              NumberToken(state.result!),
              OperatorToken(repeat.operation),
              repeat.operand,
            ],
          ),
        );
      case InputPhase.editing:
        break;
    }

    final tokens = _completeExpression(state);
    if (tokens == null) return InputUpdated(state);
    return EvaluationRequested(EvaluationRequest(tokens: tokens));
  }

  /// The tokens to evaluate, or `null` when there is nothing to calculate.
  List<InputToken>? _completeExpression(CalculatorInputState state) {
    final tokens = [...state.tokens];
    final entry = state.entry;

    if (entry != null) {
      tokens.add(_commit(entry, isPercent: state.entryIsPercent));
    } else if (tokens.isNotEmpty) {
      // A trailing operator reuses the operand on its left: 5 + = is 5 + 5.
      tokens.add(tokens[tokens.length - 2]);
    } else {
      return null;
    }

    // A lone operand is not a calculation, unless it carries a percent sign.
    final first = tokens.first;
    final isCalculation =
        tokens.length > 1 || (first is NumberToken && first.isPercent);
    return isCalculation ? tokens : null;
  }

  CalculatorInputState _withEntry(CalculatorInputState state, String? entry) {
    return CalculatorInputState(tokens: state.tokens, entry: entry);
  }

  NumberToken _commit(String entry, {required bool isPercent}) {
    return NumberToken(_normalize(entry), isPercent: isPercent);
  }

  /// Drops a dangling separator and the sign of zero.
  String _normalize(String entry) {
    final trimmed = entry.endsWith(_decimalPoint)
        ? entry.substring(0, entry.length - 1)
        : entry;
    return trimmed == '$_negativeSign$_zero' ? _zero : trimmed;
  }

  String _negate(String text) => text.startsWith(_negativeSign)
      ? text.substring(_negativeSign.length)
      : '$_negativeSign$text';

  int _digitCount(String text) => text.replaceAll(_nonDigits, '').length;
}
