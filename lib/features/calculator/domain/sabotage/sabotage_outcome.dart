import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';

/// What the engine decided for one expression.
class SabotageOutcome extends Equatable {
  /// Creates an outcome.
  const SabotageOutcome({
    required this.truth,
    required this.shown,
    required this.kind,
  });

  /// The exact result.
  final Decimal truth;

  /// The wrong result the user sees, with at most 15 significant digits.
  final Decimal shown;

  /// How the lie was made. Only the debug overlay reads it.
  final SabotageKind kind;

  /// Canonical decimal text of [shown], ready for the input reducer.
  String get shownText => canonicalText(shown);

  @override
  List<Object> get props => [truth, shown, kind];
}
