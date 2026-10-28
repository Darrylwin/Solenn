/// How the user left the paywall without choosing a plan.
///
/// Every exit leads to the same place: the app unlocks for the launch. The
/// reason is kept for the debug overlay and for tests.
enum DismissReason {
  /// The close button.
  closeButton,

  /// The decline link.
  declined,

  /// The system back button or gesture.
  systemBack,
}
