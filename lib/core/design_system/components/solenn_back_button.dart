import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/components/solenn_icon_button.dart';
import 'package:solenn/core/platform/platform.dart';

/// A circular back button whose arrow follows the host platform: a chevron on
/// iOS, the Material arrow on Android.
class SolennBackButton extends StatelessWidget {
  /// Creates a back button.
  const SolennBackButton({
    required this.semanticLabel,
    required this.onPressed,
    super.key,
  });

  /// Spoken description of the button.
  final String semanticLabel;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SolennIconButton(
      icon: context.usesCupertinoStyle
          ? Icons.arrow_back_ios_new_rounded
          : Icons.arrow_back_rounded,
      semanticLabel: semanticLabel,
      onPressed: onPressed,
    );
  }
}
