import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

/// A small accent badge with an uppercase label, such as PLUS.
class SolennChip extends StatelessWidget {
  /// Creates a chip showing [label].
  const SolennChip({required this.label, super.key});

  /// Visible label. Callers pass it already uppercase.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(context.radii.chip),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.xs,
        ),
        child: Text(
          label,
          maxLines: 1,
          style: context.type.caps.copyWith(color: colors.onAccent),
        ),
      ),
    );
  }
}
