import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/engine/evaluation_result.dart';
import 'package:solenn/features/calculator/domain/engine/expression_evaluator.dart';
import 'package:solenn/features/calculator/domain/engine/expression_parser.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_reducer.dart';
import 'package:solenn/features/calculator/domain/input/calculator_input_state.dart';
import 'package:solenn/features/calculator/domain/input/calculator_key.dart';
import 'package:solenn/features/calculator/domain/input/reduction_result.dart';

int _significantDigits(String text) {
  final digits = text.replaceAll('-', '').replaceAll('.', '');
  return digits
      .replaceFirst(RegExp('^0+'), '')
      .replaceFirst(RegExp(r'0+$'), '')
      .length;
}

void main() {
  test('should evaluate every request the reducer can produce', () {
    const reducer = CalculatorInputReducer();
    const parser = ExpressionParser();
    const evaluator = ExpressionEvaluator();
    final canonical = RegExp(r'^-?\d+(\.\d+)?$');
    final random = Random(2026);

    for (var run = 0; run < 1000; run++) {
      var state = const CalculatorInputState();
      for (var step = 0; step < 40; step++) {
        final key =
            CalculatorKey.values[random.nextInt(CalculatorKey.values.length)];

        switch (reducer.reduce(state, key)) {
          case InputUpdated(state: final next):
            state = next;
          case EvaluationRequested(:final request):
            switch (evaluator.evaluate(parser.parse(request.tokens))) {
              case EvaluationSuccess(:final text):
                expect(text, matches(canonical));
                expect(
                  _significantDigits(text),
                  lessThanOrEqualTo(significantDigits),
                );
                state = reducer.complete(request, result: text);
              case EvaluationFailure():
                state = reducer.completeWithError(request);
            }
        }
      }
    }
  });
}
