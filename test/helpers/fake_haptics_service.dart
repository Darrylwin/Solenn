import 'package:solenn/core/platform/platform.dart';

/// Kinds of haptic feedback recorded by [FakeHapticsService].
enum HapticKind { selection, light, medium }

/// [HapticsService] that records calls instead of vibrating.
class FakeHapticsService implements HapticsService {
  /// Feedback requested so far, in order.
  final List<HapticKind> events = [];

  @override
  void selection() => events.add(HapticKind.selection);

  @override
  void light() => events.add(HapticKind.light);

  @override
  void medium() => events.add(HapticKind.medium);
}
