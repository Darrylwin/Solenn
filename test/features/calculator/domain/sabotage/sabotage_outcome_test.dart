import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_outcome.dart';

import '../../../../helpers/sabotage_fixtures.dart';

void main() {
  test('should expose the shown value as canonical text', () {
    final outcome = SabotageOutcome(
      truth: decimal('144'),
      shown: decimal('414.50'),
      kind: SabotageKind.digitShuffle,
    );

    expect(outcome.shownText, '414.5');
  });

  test('should compare outcomes by value', () {
    SabotageOutcome build(String shown) => SabotageOutcome(
      truth: decimal('144'),
      shown: decimal(shown),
      kind: SabotageKind.digitShuffle,
    );

    expect(build('414'), build('414.0'));
    expect(build('414'), isNot(build('141')));
  });
}
