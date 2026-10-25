import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/sabotage/plausibility.dart';

import '../../../../helpers/sabotage_fixtures.dart';

bool _plausible(String shown, String truth) =>
    isPlausible(shown: decimal(shown), truth: decimal(truth));

void main() {
  group('isPlausible', () {
    test('should accept a nearby value of the same sign', () {
      expect(_plausible('414', '144'), isTrue);
      expect(_plausible('-414', '-144'), isTrue);
    });

    test('should accept one order of magnitude of difference', () {
      expect(_plausible('1440', '144'), isTrue);
      expect(_plausible('14', '144'), isTrue);
    });

    test('should reject two orders of magnitude of difference', () {
      expect(_plausible('14400', '144'), isFalse);
      expect(_plausible('1', '144'), isFalse);
    });

    test('should reject a flipped sign', () {
      expect(_plausible('-144', '144'), isFalse);
      expect(_plausible('144', '-144'), isFalse);
    });

    test('should reject zero', () {
      expect(_plausible('0', '144'), isFalse);
    });

    test('should reject a value out of range', () {
      expect(_plausible('1${'0' * 100}', '9${'0' * 99}'), isFalse);
    });

    test('should accept a small positive number for a zero truth', () {
      expect(_plausible('1', '0'), isTrue);
      expect(_plausible('3', '0'), isTrue);
    });

    test('should reject anything else for a zero truth', () {
      expect(_plausible('-1', '0'), isFalse);
      expect(_plausible('50', '0'), isFalse);
      expect(_plausible('0', '0'), isFalse);
    });
  });
}
