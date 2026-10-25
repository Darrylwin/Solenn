import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

const double _hairline = 1;

/// Key of the dividers between tiles, exposed so tests can count them.
const Key solennListDividerKey = Key('solenn.list.divider');

/// A rounded surface that stacks [children] (usually `SolennListTile`s)
/// separated by hairlines. The surface clips press feedback to its corners.
class SolennListGroup extends StatelessWidget {
  /// Creates a group around [children].
  const SolennListGroup({required this.children, super.key});

  /// Tiles of the group, top to bottom.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radii.planCard),
      child: ColoredBox(
        color: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                  child: SizedBox(
                    height: _hairline,
                    child: ColoredBox(
                      key: solennListDividerKey,
                      color: colors.outline,
                    ),
                  ),
                ),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}
