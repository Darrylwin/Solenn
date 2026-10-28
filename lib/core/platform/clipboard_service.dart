/// Access to the system clipboard, abstracted so that it can be faked in
/// tests.
abstract interface class ClipboardService {
  /// Puts [text] on the clipboard.
  Future<void> copy(String text);
}
