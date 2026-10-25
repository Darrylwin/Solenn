import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/calculation_session.dart';

class _Case {
  const _Case(this.keys, this.expected);

  final String keys;
  final String expected;
}

List<_Case> _loadCases() {
  final cases = <_Case>[];
  final lines = File('test/fixtures/evaluator_cases.csv').readAsLinesSync();

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    final parts = line.split(',');
    if (parts.length != 2) {
      throw StateError('Malformed case: $line');
    }
    cases.add(_Case(parts[0], parts[1]));
  }
  return cases;
}

void main() {
  final cases = _loadCases();

  group('conformance file', () {
    test('should hold at least 200 cases', () {
      expect(cases.length, greaterThanOrEqualTo(200));
    });

    test('should not repeat a case', () {
      final keys = cases.map((testCase) => testCase.keys).toList();

      expect(keys.toSet().length, keys.length);
    });

    test('should only use known keys', () {
      for (final testCase in cases) {
        for (final character in testCase.keys.split('')) {
          expect(
            calculatorKeysByCharacter.containsKey(character),
            isTrue,
            reason: '"$character" in ${testCase.keys}',
          );
        }
      }
    });
  });

  group('evaluator conformance', () {
    for (final testCase in cases) {
      test('${testCase.keys} should display ${testCase.expected}', () {
        final session = CalculationSession()..press(testCase.keys);

        expect(session.display, testCase.expected);
      });
    }
  });
}
