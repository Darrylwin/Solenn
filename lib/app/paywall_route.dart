import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';

// With reduced motion the paywall fades instead of sliding, and quickly.
const Duration _reducedMotionDuration = Duration(milliseconds: 120);

/// The route of the paywall: a full-screen modal that slides up.
///
/// When the user asked for less motion (`disableAnimations`), it is a short
/// fade. The route draws no back gesture of its own: the paywall decides what
/// the system back means.
PageRouteBuilder<void> buildPaywallRoute(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final motion = context.motion;
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  final slide = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).chain(CurveTween(curve: motion.emphasized));

  return PageRouteBuilder<void>(
    fullscreenDialog: true,
    transitionDuration: reduceMotion ? _reducedMotionDuration : motion.slow,
    reverseTransitionDuration: reduceMotion
        ? _reducedMotionDuration
        : motion.base,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (reduceMotion) return FadeTransition(opacity: animation, child: child);
      return SlideTransition(position: animation.drive(slide), child: child);
    },
  );
}
