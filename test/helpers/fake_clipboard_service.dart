import 'package:solenn/core/platform/platform.dart';

/// [ClipboardService] that records what was copied.
class FakeClipboardService implements ClipboardService {
  /// Texts copied so far, in order.
  final List<String> copied = [];

  @override
  Future<void> copy(String text) async => copied.add(text);
}
