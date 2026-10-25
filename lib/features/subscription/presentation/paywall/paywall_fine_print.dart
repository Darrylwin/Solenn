import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/design_system.dart';
import 'package:solenn/l10n/l10n.dart';

/// Initial value of the decorative offer countdown.
const Duration paywallOfferDuration = Duration(minutes: 5);

const Duration _tick = Duration(seconds: 1);
const String _separator = ' · ';

/// Formats [remaining] as `mm:ss`. A negative duration reads `00:00`.
String formatCountdown(Duration remaining) {
  final total = remaining.isNegative ? Duration.zero : remaining;
  final minutes = total.inMinutes.toString().padLeft(2, '0');
  final seconds = total.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// The line under the call to action: a price reminder followed by the
/// offer countdown.
///
/// The countdown is decorative. It restarts from [offerDuration] when it
/// reaches zero and never blocks anything.
class PaywallFinePrint extends StatefulWidget {
  /// Creates the fine print showing [text] before the countdown.
  const PaywallFinePrint({
    required this.text,
    this.offerDuration = paywallOfferDuration,
    super.key,
  });

  /// Price reminder, for example `Then $39.99 / year`.
  final String text;

  /// Starting value of the countdown.
  final Duration offerDuration;

  @override
  State<PaywallFinePrint> createState() => _PaywallFinePrintState();
}

class _PaywallFinePrintState extends State<PaywallFinePrint> {
  late Duration _remaining = widget.offerDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Reading the late field starts the timer.
    _timer = Timer.periodic(_tick, (_) => _advance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() {
    final next = _remaining - _tick;
    setState(() {
      _remaining = next > Duration.zero ? next : widget.offerDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = context.type.bodySmall.copyWith(
      color: context.colors.textSecondary,
    );
    final countdown = context.l10n.paywallOfferCountdown(
      formatCountdown(_remaining),
    );

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: widget.text),
          const TextSpan(text: _separator),
          TextSpan(text: countdown),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
