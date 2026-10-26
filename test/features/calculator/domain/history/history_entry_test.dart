import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/history/history_entry.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';

void main() {
  test('should compare entries by value', () {
    const tokens = [NumberToken('5')];

    expect(
      const HistoryEntry(tokens: tokens, result: '5'),
      const HistoryEntry(tokens: tokens, result: '5'),
    );
    expect(
      const HistoryEntry(tokens: tokens, result: '5'),
      isNot(const HistoryEntry(tokens: tokens, result: '6')),
    );
  });
}
