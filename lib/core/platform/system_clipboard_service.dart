import 'package:flutter/services.dart';
import 'package:solenn/core/platform/clipboard_service.dart';

/// [ClipboardService] backed by the platform clipboard.
class SystemClipboardService implements ClipboardService {
  /// Creates the service.
  const SystemClipboardService();

  @override
  Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
