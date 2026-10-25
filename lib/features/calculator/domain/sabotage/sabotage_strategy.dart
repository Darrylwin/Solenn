import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_context.dart';
import 'package:solenn/features/calculator/domain/sabotage/sabotage_kind.dart';

/// One way of lying about a result.
abstract interface class SabotageStrategy {
  /// The kind this strategy implements.
  SabotageKind get kind;

  /// A wrong value for [context], or `null` when the strategy does not apply
  /// (a single digit cannot be shuffled).
  ///
  /// The engine checks every candidate, so a strategy only has to try.
  Decimal? apply(SabotageContext context);
}
