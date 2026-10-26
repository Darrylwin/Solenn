import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/formatting/calculator_display_formatter.dart';
import 'package:solenn/features/calculator/domain/formatting/number_symbols.dart';

import '../../../../helpers/calculation_session.dart';

CalculatorDisplayFormatter _formatter = CalculatorDisplayFormatter(
  NumberSymbols.english,
);

FormattedDisplay _show(String keys) => _formatter.format(
  CalculationSession().press(keys).state,
  errorLabel: 'Error',
);

void _expectDisplay(String keys, String expression, String result) {
  test('$keys should show "$expression" over "$result"', () {
    expect(
      _show(keys),
      FormattedDisplay(expression: expression, result: result),
    );
  });
}

void main() {
  group('while typing', () {
    _expectDisplay('', '', '0');
    _expectDisplay('5', '', '5');
    _expectDisplay('12345678.9', '', '12,345,678.9');
    _expectDisplay('5.', '', '5.');
    _expectDisplay('1.50', '', '1.50');
    _expectDisplay('~', '', '-0');
    _expectDisplay('~5', '', '-5');
    _expectDisplay('5%', '', '5%');
    _expectDisplay('5+', '5 +', '5');
    _expectDisplay('5+3', '5 +', '3');
    _expectDisplay('5+3*', '5 + 3 \u00D7', '3');
    _expectDisplay('5+3.', '5 +', '3.');
    _expectDisplay('50+10%', '50 +', '10%');
  });

  group('after a calculation', () {
    _expectDisplay('5+3=', '5 + 3', '8');
    _expectDisplay('24000+220=', '24,000 + 220', '24,220');
    _expectDisplay('2+3*4=', '2 + 3 \u00D7 4', '14');
    _expectDisplay('9-3=', '9 \u2212 3', '6');
    _expectDisplay('8/2=', '8 \u00F7 2', '4');
    _expectDisplay('1/3=', '1 \u00F7 3', '0.333333333');
    _expectDisplay('50+10%=', '50 + 10%', '55');
    _expectDisplay('5%=', '5%', '0.05');
    _expectDisplay('1.50+1=', '1.5 + 1', '2.5');
    _expectDisplay('999999999*10=', '999,999,999 \u00D7 10', '9.99999999e+9');
    _expectDisplay('3-5=', '3 \u2212 5', '-2');
  });

  group('after a result', () {
    _expectDisplay('2+3=*', '5 \u00D7', '5');
    _expectDisplay('2+3=~', '', '-5');
    _expectDisplay('2+3=%', '', '5%');
    _expectDisplay('2+3=7', '', '7');
  });

  group('after an error', () {
    _expectDisplay('1/0=', '1 \u00F7 0', 'Error');
    _expectDisplay('1/0=+', '1 \u00F7 0', 'Error');
  });

  test('should use the given error label', () {
    final display = _formatter.format(
      CalculationSession().press('1/0=').state,
      errorLabel: 'Erreur',
    );

    expect(display.result, 'Erreur');
  });

  test('should write numbers with the given symbols', () {
    final french = CalculatorDisplayFormatter(
      const NumberSymbols(decimalSeparator: ',', groupSeparator: '\u202F'),
    );
    final display = french.format(
      CalculationSession().press('24000+220.5=').state,
      errorLabel: 'Erreur',
    );

    expect(display.expression, '24\u202F000 + 220,5');
    expect(display.result, '24\u202F220,5');
  });

  test('should compare displays by value', () {
    expect(
      const FormattedDisplay(expression: 'a', result: 'b'),
      const FormattedDisplay(expression: 'a', result: 'b'),
    );
  });

  test('should format an expression from its tokens', () {
    final state = CalculationSession().press('24000+220=').state;

    expect(_formatter.formatExpression(state.tokens), '24,000 + 220');
    expect(_formatter.formatExpression(const []), '');
  });

  test('should format a computed number from its canonical text', () {
    expect(_formatter.formatNumber('24220'), '24,220');
    expect(_formatter.formatNumber('0.333333333333333'), '0.333333333');
    expect(_formatter.formatNumber('1234567890'), '1.23456789e+9');
  });
}
