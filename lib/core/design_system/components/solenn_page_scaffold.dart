import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/solenn_back_button.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

/// A full page with a back button, a centered title and a content area,
/// kept within the maximum content width.
///
/// The system back gesture is handled by the route; [onBackPressed] only
/// reacts to the on-screen button.
class SolennPageScaffold extends StatelessWidget {
  /// Creates a page showing [child] under [title].
  const SolennPageScaffold({
    required this.title,
    required this.backSemanticLabel,
    required this.onBackPressed,
    required this.child,
    super.key,
  });

  /// Page title, centered in the header.
  final String title;

  /// Spoken description of the back button.
  final String backSemanticLabel;

  /// Called when the back button is tapped.
  final VoidCallback onBackPressed;

  /// The page content, which fills the remaining space.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          spacing.screenMargin,
          spacing.sm,
          spacing.screenMargin,
          spacing.lg,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: spacing.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SolennBackButton(
                      semanticLabel: backSemanticLabel,
                      onPressed: onBackPressed,
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.titleMedium.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.minTouchTarget),
                  ],
                ),
                SizedBox(height: spacing.xxl),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
