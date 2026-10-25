import 'package:flutter/foundation.dart';

/// Display data of one history entry.
///
/// The view renders strings only. Formatting domain entries into these
/// strings is the job of the layer that builds the view.
@immutable
class HistoryItem {
  /// Creates the display data of an entry.
  const HistoryItem({required this.expression, required this.result});

  /// The expression as typed, for example `36×4`.
  final String expression;

  /// The result that was displayed, for example `414`.
  final String result;
}
