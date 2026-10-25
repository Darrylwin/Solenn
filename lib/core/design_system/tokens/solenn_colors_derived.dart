import 'package:flutter/painting.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors.dart';

/// Colors derived from the base palette, so that no extra token is needed.
extension SolennColorsDerived on SolennColors {
  /// Drag handle and grabber of sheets: the muted icon color at half strength.
  Color get sheetHandle => iconMuted.withValues(alpha: 0.5);
}
