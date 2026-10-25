import 'package:flutter/foundation.dart';

/// One label and value line of the purchase summary.
@immutable
class CheckoutRow {
  /// Creates a summary line.
  const CheckoutRow({required this.label, required this.value});

  /// What the line describes, for example the trial length.
  final String label;

  /// Its value.
  final String value;
}
