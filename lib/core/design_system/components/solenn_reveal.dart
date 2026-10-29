import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';

const Duration _revealDuration = Duration(milliseconds: 200);
const Duration _reducedDuration = Duration(milliseconds: 120);
const double _riseDistance = 8;

/// Fades its child in, with a short rise, each time [revealKey] changes to a
/// non-null value.
///
/// While [revealKey] is `null` the child is simply shown, so typing is never
/// animated. When the user asked for less motion the rise is dropped and the
/// fade is shortened.
class SolennReveal extends StatefulWidget {
  /// Creates a reveal around [child].
  const SolennReveal({required this.child, this.revealKey, super.key});

  /// Identifies what is on display. A change to a non-null value plays the
  /// reveal; `null` shows the child at once.
  final Object? revealKey;

  /// The content to reveal.
  final Widget child;

  @override
  State<SolennReveal> createState() => _SolennRevealState();
}

class _SolennRevealState extends State<SolennReveal>
    with SingleTickerProviderStateMixin {
  // At rest: the first build shows the child at once.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = MediaQuery.disableAnimationsOf(context)
        ? _reducedDuration
        : _revealDuration;
  }

  @override
  void didUpdateWidget(SolennReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    final key = widget.revealKey;
    if (key == null) {
      _controller.value = 1;
    } else if (key != oldWidget.revealKey) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = context.motion.standard;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress = curve.transform(_controller.value);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(
              0,
              reduceMotion ? 0 : _riseDistance * (1 - progress),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
