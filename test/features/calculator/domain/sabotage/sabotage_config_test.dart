import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_config.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_phase.dart';

void main() {
  const config = SabotageConfig.standard;

  group('phaseOf', () {
    test('should follow the phases of the specification', () {
      expect(config.phaseOf(1), SabotagePhase.plausible);
      expect(config.phaseOf(3), SabotagePhase.plausible);
      expect(config.phaseOf(4), SabotagePhase.bold);
      expect(config.phaseOf(8), SabotagePhase.bold);
      expect(config.phaseOf(9), SabotagePhase.absurd);
      expect(config.phaseOf(500), SabotagePhase.absurd);
    });

    test('should reject an index below one', () {
      expect(() => config.phaseOf(0), throwsA(isA<AssertionError>()));
    });
  });

  group('weights', () {
    test('should offer two kinds while lies must be plausible', () {
      expect(config.weightsOf(SabotagePhase.plausible), {
        SabotageKind.nearMissOffset: 60,
        SabotageKind.digitShuffle: 40,
      });
    });

    test('should not offer absurd values before the absurd phase', () {
      for (final phase in [SabotagePhase.plausible, SabotagePhase.bold]) {
        expect(
          config.weightsOf(phase).containsKey(SabotageKind.absurd),
          isFalse,
          reason: '$phase',
        );
      }
    });

    test('should keep absurd values to at most one draw in six', () {
      final weights = config.weightsOf(SabotagePhase.absurd);
      final total = weights.values.fold(0, (sum, weight) => sum + weight);

      expect(weights[SabotageKind.absurd]! / total, lessThanOrEqualTo(1 / 6));
    });

    test('should always offer the fallback strategy', () {
      for (final phase in SabotagePhase.values) {
        expect(
          config.weightsOf(phase).containsKey(SabotageKind.nearMissOffset),
          isTrue,
          reason: '$phase',
        );
      }
    });

    test('should have no weight for an unknown phase', () {
      const empty = SabotageConfig(weights: {});

      expect(empty.weightsOf(SabotagePhase.bold), isEmpty);
    });
  });

  test('should reject phases that are not in order', () {
    expect(
      () => SabotageConfig(plausibleUntil: 5, boldUntil: 5),
      throwsA(isA<AssertionError>()),
    );
  });

  test('should compare configurations by value', () {
    expect(SabotageConfig.standard, SabotageConfig.standard);
    expect(const SabotageConfig(boldUntil: 20), isNot(SabotageConfig.standard));
  });
}
