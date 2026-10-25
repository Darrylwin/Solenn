import 'package:solenn/features/calculator/domain/engine/expression.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';

/// Builds an [Expression] from the tokens of an evaluation request.
///
/// Multiplication and division bind tighter than addition and subtraction,
/// and operators of equal precedence group from the left.
///
/// A percent operand is resolved by the operator that precedes it:
///
/// - first operand, or after a multiplication or division: `B%` is `B / 100`;
/// - after an addition or subtraction: `B%` is `A x B / 100`, where `A` is the
///   whole expression to the left of that operator (the running total).
class ExpressionParser {
  /// Creates a parser. It holds no state.
  const ExpressionParser();

  /// Parses [tokens].
  ///
  /// Throws an [ArgumentError] when the tokens do not alternate between
  /// operands and operators, starting and ending with an operand. The reducer
  /// never produces such tokens, so this signals a programming error.
  Expression parse(List<InputToken> tokens) {
    if (!_isAlternating(tokens)) {
      throw ArgumentError.value(
        tokens,
        'tokens',
        'Must alternate operands and operators, starting and ending with '
            'an operand.',
      );
    }
    return _Parser(tokens).parseExpression();
  }

  bool _isAlternating(List<InputToken> tokens) {
    if (tokens.length.isEven) return false;
    for (var index = 0; index < tokens.length; index++) {
      final isExpectedKind = index.isEven
          ? tokens[index] is NumberToken
          : tokens[index] is OperatorToken;
      if (!isExpectedKind) return false;
    }
    return true;
  }
}

class _Parser {
  _Parser(this._tokens);

  final List<InputToken> _tokens;
  int _index = 0;

  Expression parseExpression() {
    var left = _parseTerm(percentBase: null);
    while (true) {
      final operation = _peekOperator();
      if (operation == null) return left;
      // Terms consume every multiplication and division, so what remains
      // here is an addition or a subtraction.
      _index++;
      left = Binary(operation, left, _parseTerm(percentBase: left));
    }
  }

  Expression _parseTerm({required Expression? percentBase}) {
    var left = _parseFactor(percentBase: percentBase);
    while (true) {
      final operation = _peekOperator();
      if (operation == null || !operation.hasHighPrecedence) return left;
      _index++;
      left = Binary(operation, left, _parseFactor(percentBase: null));
    }
  }

  Expression _parseFactor({required Expression? percentBase}) {
    final operand = _tokens[_index++] as NumberToken;
    final literal = Literal(operand.text);
    if (!operand.isPercent) return literal;

    final percent = Percent(literal);
    return percentBase == null
        ? percent
        : Binary(ArithmeticOperator.multiply, percentBase, percent);
  }

  ArithmeticOperator? _peekOperator() {
    if (_index >= _tokens.length) return null;
    return (_tokens[_index] as OperatorToken).value;
  }
}
