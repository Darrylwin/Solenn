/// The ways the engine can lie about a result.
enum SabotageKind {
  /// Shifts one of the three most significant digits by one to three units.
  nearMissOffset,

  /// Swaps two adjacent digits.
  digitShuffle,

  /// Rounds to the nearest 10, 100 or 1000.
  roundingAbuse,

  /// Recomputes the last operation with another operator.
  wrongOperator,

  /// Answers with a curated, ridiculous value.
  absurd,
}
