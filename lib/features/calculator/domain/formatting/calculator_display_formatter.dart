import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/formatting/number_formatter.dart';
import 'package:solenn/features/calculator/domain/formatting/number_symbols.dart';
import 'package:solenn/features/calculator/domain/formatting/operator_glyph.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';

/// The two lines of the display, ready to draw.
class FormattedDisplay extends Equatable {
  /// Creates the two lines.
  const FormattedDisplay({required this.expression, required this.result});

  /// The first line: the expression, or an empty text before any operator.
  final String expression;

  /// The second line: the number being typed, or the result.
  final String result;

  @override
  List<Object> get props => [expression, result];
}

/// Turns the input state into the text of the display.
///
/// There is no live preview (specification section 7.1): while typing, the
/// first line shows what was committed (`5 +`) and the second line the number
/// being typed. After `=`, the first line shows the whole expression and the
/// second line its result.
class CalculatorDisplayFormatter {
  /// Creates a formatter that writes numbers with [symbols].
  CalculatorDisplayFormatter(NumberSymbols symbols)
    : _numbers = NumberFormatter(symbols);

  final NumberFormatter _numbers;

  /// Formats [state]. [errorLabel] is the localized text shown after a failed
  /// evaluation, which the domain cannot know.
  FormattedDisplay format(
    CalculatorInputState state, {
    required String errorLabel,
  }) {
    return FormattedDisplay(
      expression: state.tokens.map(_formatToken).join(' '),
      result: _formatResult(state, errorLabel),
    );
  }

  String _formatToken(InputToken token) => switch (token) {
    NumberToken(:final text, :final isPercent) => _numbers.formatValue(
      text,
      isPercent: isPercent,
    ),
    OperatorToken(:final value) => operatorGlyph(value),
  };

  String _formatResult(CalculatorInputState state, String errorLabel) {
    if (state.isError) return errorLabel;

    final entry = state.entry;
    if (entry != null) {
      return _numbers.formatEntry(entry, isPercent: state.entryIsPercent);
    }
    final number = state.displayedNumber;
    return _numbers.formatValue(number.text, isPercent: number.isPercent);
  }
}
