import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/input/arithmetic_operator.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_reducer.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/domain/input/evaluation_request.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';
import 'package:solenn/features/calculator/domain/input/reduction_result.dart';
import 'package:solenn/features/calculator/domain/input/repeat_operation.dart';

const CalculatorInputReducer _reducer = CalculatorInputReducer();

const Map<String, CalculatorKey> _keysByCharacter = {
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

/// Plays a key sequence against the reducer, answering each evaluation
/// request with [resultFor]. A `null` answer is an evaluation error.
class _Session {
  _Session({String? Function(EvaluationRequest request)? resultFor})
    : _resultFor = resultFor ?? ((_) => '0');

  final String? Function(EvaluationRequest request) _resultFor;
  final List<EvaluationRequest> requests = [];
  CalculatorInputState state = const CalculatorInputState();

  _Session press(String keys) {
    for (final character in keys.split('')) {
      switch (_reducer.reduce(state, _keysByCharacter[character]!)) {
        case InputUpdated(state: final next):
          state = next;
        case EvaluationRequested(:final request):
          requests.add(request);
          final result = _resultFor(request);
          state = result == null
              ? _reducer.completeWithError(request)
              : _reducer.complete(request, result: result);
      }
    }
    return this;
  }
}

const NumberToken _one = NumberToken('1');
const NumberToken _five = NumberToken('5');
const OperatorToken _add = OperatorToken(ArithmeticOperator.add);
const OperatorToken _multiply = OperatorToken(ArithmeticOperator.multiply);
const OperatorToken _divide = OperatorToken(ArithmeticOperator.divide);

void main() {
  group('digits', () {
    test('should build a number from digits', () {
      expect(_Session().press('123').state.entry, '123');
    });

    test('should collapse leading zeros', () {
      expect(_Session().press('007').state.entry, '7');
      expect(_Session().press('000').state.entry, '0');
    });

    test('should cap an operand at nine digits', () {
      expect(_Session().press('1234567890').state.entry, '123456789');
    });

    test('should not count the sign or the separator as digits', () {
      expect(_Session().press('~123456789').state.entry, '-123456789');
      expect(_Session().press('12345678.99').state.entry, '12345678.9');
    });

    test('should type a decimal number', () {
      expect(_Session().press('1.25').state.entry, '1.25');
    });

    test('should start with 0. when the separator comes first', () {
      expect(_Session().press('.5').state.entry, '0.5');
    });

    test('should ignore a second separator', () {
      expect(_Session().press('1.2.3').state.entry, '1.23');
    });

    test('should keep a trailing separator while typing', () {
      expect(_Session().press('5.').state.entry, '5.');
    });

    test('should keep the committed tokens while typing', () {
      final state = _Session().press('5+32').state;

      expect(state.tokens, [_five, _add]);
      expect(state.entry, '32');
    });

    test('should start a new expression after a result', () {
      final session = _Session(resultFor: (_) => '2')..press('1+1=');
      expect(session.state.result, '2');

      session.press('5');

      expect(session.state.entry, '5');
      expect(session.state.tokens, isEmpty);
      expect(session.state.phase, InputPhase.editing);
      expect(session.state.result, isNull);
    });

    test(
      'should start a new expression after a separator following a result',
      () {
        final session = _Session(resultFor: (_) => '2')..press('1+1=.');

        expect(session.state.entry, '0.');
        expect(session.state.tokens, isEmpty);
      },
    );

    test('should start a new expression after an error', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=');
      expect(session.state.isError, isTrue);

      session.press('7');

      expect(session.state, const CalculatorInputState(entry: '7'));
    });
  });

  group('operators', () {
    test('should commit the entry and wait for the next operand', () {
      final state = _Session().press('5+').state;

      expect(state.tokens, [_five, _add]);
      expect(state.entry, isNull);
      expect(state.pendingOperator, ArithmeticOperator.add);
    });

    test('should replace an operator typed after another operator', () {
      expect(_Session().press('5+*').state.tokens, [_five, _multiply]);
    });

    test('should chain operations', () {
      expect(
        _Session().press('5+3*').state.tokens,
        [_five, _add, const NumberToken('3'), _multiply],
      );
    });

    test('should use zero when no operand was typed', () {
      expect(
        _Session().press('+').state.tokens,
        [const NumberToken('0'), _add],
      );
    });

    test('should drop a dangling separator when committing', () {
      expect(_Session().press('5.+').state.tokens, [_five, _add]);
    });

    test('should commit a signed zero as zero', () {
      expect(
        _Session().press('~+').state.tokens,
        [const NumberToken('0'), _add],
      );
    });

    test('should keep the percent sign of a committed operand', () {
      expect(
        _Session().press('5%+').state.tokens,
        [const NumberToken('5', isPercent: true), _add],
      );
    });

    test('should continue from the displayed result', () {
      final session = _Session(resultFor: (_) => '2')..press('1+1=*');

      expect(session.state.tokens, [const NumberToken('2'), _multiply]);
      expect(session.state.phase, InputPhase.editing);
      expect(session.state.result, isNull);
    });

    test('should be ignored after an error', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=');
      final before = session.state;

      session.press('+');

      expect(session.state, before);
    });
  });

  group('equals', () {
    test('should request the evaluation of a complete expression', () {
      final session = _Session()..press('5+3=');

      expect(
        session.requests.single.tokens,
        [_five, _add, const NumberToken('3')],
      );
    });

    test('should leave a lone operand alone', () {
      final session = _Session()..press('5=');

      expect(session.requests, isEmpty);
      expect(session.state.entry, '5');
    });

    test('should do nothing on an empty input', () {
      final session = _Session()..press('=');

      expect(session.requests, isEmpty);
      expect(session.state, const CalculatorInputState());
    });

    test('should reuse the left operand after a trailing operator', () {
      final session = _Session()..press('5+=');

      expect(session.requests.single.tokens, [_five, _add, _five]);
    });

    test('should reuse the operand next to a trailing operator', () {
      final session = _Session()..press('2+3*=');

      expect(
        session.requests.single.tokens,
        [
          const NumberToken('2'),
          _add,
          const NumberToken('3'),
          _multiply,
          const NumberToken('3'),
        ],
      );
    });

    test('should evaluate a lone percent', () {
      final session = _Session()..press('5%=');

      expect(
        session.requests.single.tokens,
        [const NumberToken('5', isPercent: true)],
      );
    });

    test('should drop a dangling separator in the request', () {
      final session = _Session()..press('5+3.=');

      expect(session.requests.single.tokens.last, const NumberToken('3'));
    });

    test('should store the evaluated expression and its result', () {
      final session = _Session(resultFor: (_) => '2')..press('1+1=');

      expect(session.state.phase, InputPhase.evaluated);
      expect(session.state.tokens, [_one, _add, _one]);
      expect(session.state.result, '2');
      expect(session.state.entry, isNull);
    });

    test('should remember the last operation for a repeated equals', () {
      final session = _Session()..press('2+3*4=');

      expect(
        session.state.repeat,
        const RepeatOperation(
          operation: ArithmeticOperator.multiply,
          operand: NumberToken('4'),
        ),
      );
    });

    test('should repeat the last operation on the displayed result', () {
      final results = ['5', '8', '11'];
      final session = _Session(resultFor: (_) => results.removeAt(0))
        ..press('2+3==');

      expect(
        session.requests[1].tokens,
        [const NumberToken('5'), _add, const NumberToken('3')],
      );

      session.press('=');

      expect(
        session.requests[2].tokens,
        [const NumberToken('8'), _add, const NumberToken('3')],
      );
      expect(session.state.result, '11');
    });

    test('should have nothing to repeat after a lone percent', () {
      final session = _Session(resultFor: (_) => '0.05')..press('5%==');

      expect(session.requests, hasLength(1));
    });

    test('should be ignored after an error', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=');
      final before = session.state;

      session.press('=');

      expect(session.requests, hasLength(1));
      expect(session.state, before);
    });

    test('should keep the expression when the evaluation fails', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=');

      expect(session.state.phase, InputPhase.error);
      expect(
        session.state.tokens,
        [_one, _divide, const NumberToken('0')],
      );
      expect(session.state.result, isNull);
    });
  });

  group('toggle sign', () {
    test('should flip the sign of the entry', () {
      expect(_Session().press('5~').state.entry, '-5');
      expect(_Session().press('5~~').state.entry, '5');
    });

    test('should start a negative number from an empty input', () {
      expect(_Session().press('~').state.entry, '-0');
      expect(_Session().press('~5').state.entry, '-5');
    });

    test('should start a negative operand after an operator', () {
      final state = _Session().press('5+~3').state;

      expect(state.tokens, [_five, _add]);
      expect(state.entry, '-3');
    });

    test('should flip the sign of the displayed result and continue', () {
      final session = _Session(resultFor: (_) => '2')..press('1+1=~');

      expect(session.state.entry, '-2');
      expect(session.state.tokens, isEmpty);
      expect(session.state.phase, InputPhase.editing);
    });

    test('should turn a negative result positive', () {
      final session = _Session(resultFor: (_) => '-2')..press('1-3=~');

      expect(session.state.entry, '2');
    });

    test('should keep the percent sign', () {
      final state = _Session().press('5%~').state;

      expect(state.entry, '-5');
      expect(state.entryIsPercent, isTrue);
    });

    test('should be ignored after an error', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=');
      final before = session.state;

      session.press('~');

      expect(session.state, before);
    });
  });

  group('percent', () {
    test('should mark the entry as a percentage', () {
      final state = _Session().press('5%').state;

      expect(state.entry, '5');
      expect(state.entryIsPercent, isTrue);
    });

    test('should close the operand to digits and separators', () {
      expect(_Session().press('5%3').state.entry, '5');
      expect(_Session().press('5%.').state.entry, '5');
    });

    test('should ignore a second percent sign', () {
      final once = _Session().press('5%').state;

      expect(_Session().press('5%%').state, once);
    });

    test('should do nothing without an operand', () {
      expect(_Session().press('%').state, const CalculatorInputState());
      expect(_Session().press('5+%').state, _Session().press('5+').state);
    });

    test('should apply to the displayed result', () {
      final session = _Session(resultFor: (_) => '2')..press('1+1=%');

      expect(session.state.entry, '2');
      expect(session.state.entryIsPercent, isTrue);
      expect(session.state.tokens, isEmpty);
    });

    test('should be removed by the first backspace', () {
      final state = _Session().press('5%B').state;

      expect(state.entry, '5');
      expect(state.entryIsPercent, isFalse);
    });

    test('should be ignored after an error', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=');
      final before = session.state;

      session.press('%');

      expect(session.state, before);
    });
  });

  group('backspace', () {
    test('should delete the last digit', () {
      expect(_Session().press('123B').state.entry, '12');
    });

    test('should clear a single digit', () {
      expect(_Session().press('5B').state.entry, isNull);
    });

    test('should clear a lone negative digit entirely', () {
      expect(_Session().press('~5B').state.entry, isNull);
    });

    test('should delete a separator', () {
      expect(_Session().press('.B').state.entry, '0');
    });

    test('should do nothing without an entry', () {
      final before = _Session().press('5+').state;

      expect(_Session().press('5+B').state, before);
    });

    test('should leave the committed tokens when the entry is erased', () {
      final state = _Session().press('5+3B').state;

      expect(state.tokens, [_five, _add]);
      expect(state.entry, isNull);
      expect(state.pendingOperator, ArithmeticOperator.add);
    });

    test('should do nothing on a result', () {
      final session = _Session(resultFor: (_) => '2')..press('1+1=');
      final before = session.state;

      session.press('B');

      expect(session.state, before);
    });

    test('should do nothing after an error', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=');
      final before = session.state;

      session.press('B');

      expect(session.state, before);
    });
  });

  group('clear', () {
    test('should reset an expression in progress', () {
      expect(_Session().press('5+3C').state, const CalculatorInputState());
    });

    test('should reset a result and its repeat operation', () {
      final session = _Session(resultFor: (_) => '2')..press('1+1=C');

      expect(session.state, const CalculatorInputState());
    });

    test('should reset an error', () {
      final session = _Session(resultFor: (_) => null)..press('1/0=C');

      expect(session.state, const CalculatorInputState());
    });
  });

  group('invariants', () {
    int digitCount(String text) => text.replaceAll(RegExp('[^0-9]'), '').length;

    void expectInvariants(CalculatorInputState state) {
      final entry = state.entry;
      if (entry != null) {
        expect(digitCount(entry), lessThanOrEqualTo(maxEntryDigits));
      }
      if (state.entryIsPercent) expect(entry, isNotNull);
      if (state.pendingOperator != null) expect(entry, isNull);

      for (var index = 0; index < state.tokens.length; index++) {
        expect(
          state.tokens[index],
          index.isEven ? isA<NumberToken>() : isA<OperatorToken>(),
        );
      }

      switch (state.phase) {
        case InputPhase.editing:
          expect(state.tokens.length.isEven, isTrue);
          expect(state.result, isNull);
        case InputPhase.evaluated:
          expect(state.tokens.length.isOdd, isTrue);
          expect(state.result, isNotNull);
          expect(entry, isNull);
        case InputPhase.error:
          expect(state.tokens.length.isOdd, isTrue);
          expect(state.result, isNull);
          expect(entry, isNull);
      }
    }

    test('should hold under random key sequences', () {
      final random = Random(2026);

      for (var run = 0; run < 2000; run++) {
        var state = const CalculatorInputState();
        for (var step = 0; step < 40; step++) {
          final key =
              CalculatorKey.values[random.nextInt(CalculatorKey.values.length)];
          switch (_reducer.reduce(state, key)) {
            case InputUpdated(state: final next):
              state = next;
            case EvaluationRequested(:final request):
              state = random.nextInt(5) == 0
                  ? _reducer.completeWithError(request)
                  : _reducer.complete(
                      request,
                      result: '${random.nextInt(1000)}',
                    );
          }
          expectInvariants(state);
        }
      }
    });
  });
}
