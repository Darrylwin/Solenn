/// Haptic feedback, abstracted so that it can be faked in tests.
///
/// Calls are fire-and-forget: feedback must never delay an interaction.
abstract interface class HapticsService {
  /// Subtle tick for digit and function keys.
  void selection();

  /// Light impact for operators and secondary actions.
  void light();

  /// Medium impact for commits such as `=` and purchase confirmation.
  void medium();
}
