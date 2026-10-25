import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_phase.dart';

// Selection weights per phase. Absurd values never
// appear before the absurd phase and stay at 15 percent once they do.
const Map<SabotagePhase, Map<SabotageKind, int>> _standardWeights = {
  SabotagePhase.plausible: {
    SabotageKind.nearMissOffset: 60,
    SabotageKind.digitShuffle: 40,
  },
  SabotagePhase.bold: {
    SabotageKind.nearMissOffset: 30,
    SabotageKind.digitShuffle: 25,
    SabotageKind.roundingAbuse: 20,
    SabotageKind.wrongOperator: 25,
  },
  SabotagePhase.absurd: {
    SabotageKind.nearMissOffset: 20,
    SabotageKind.digitShuffle: 20,
    SabotageKind.roundingAbuse: 20,
    SabotageKind.wrongOperator: 25,
    SabotageKind.absurd: 15,
  },
};

/// Every tunable constant of the sabotage engine, in one place.
class SabotageConfig extends Equatable {
  /// Creates a configuration.
  const SabotageConfig({
    this.plausibleUntil = 3,
    this.boldUntil = 8,
    this.weights = _standardWeights,
  }) : assert(plausibleUntil >= 1, 'The plausible phase needs a calculation.'),
       assert(boldUntil > plausibleUntil, 'The bold phase must follow.');

  /// The configuration shipped with the application.
  static const SabotageConfig standard = SabotageConfig();

  /// Last calculation index of the plausible phase.
  final int plausibleUntil;

  /// Last calculation index of the bold phase.
  final int boldUntil;

  /// Selection weights of each kind, per phase. A missing kind is not eligible.
  final Map<SabotagePhase, Map<SabotageKind, int>> weights;

  /// The phase of the calculation numbered [calculationIndex] (1 is the first
  /// successful calculation of the launch).
  SabotagePhase phaseOf(int calculationIndex) {
    assert(calculationIndex >= 1, 'Calculation indexes start at 1.');
    if (calculationIndex <= plausibleUntil) return SabotagePhase.plausible;
    if (calculationIndex <= boldUntil) return SabotagePhase.bold;
    return SabotagePhase.absurd;
  }

  /// The selection weights of [phase].
  Map<SabotageKind, int> weightsOf(SabotagePhase phase) =>
      weights[phase] ?? const {};

  @override
  List<Object> get props => [plausibleUntil, boldUntil, weights];
}
