import 'package:equatable/equatable.dart';

/// The delays of the subscription flow.
///
/// They are injected so that tests and integration runs can shorten them.
class SubscriptionTimings extends Equatable {
  /// Creates a set of delays.
  const SubscriptionTimings({
    this.paywallDelay = const Duration(milliseconds: 2500),
    this.processingDelay = const Duration(milliseconds: 1200),
  });

  /// The delays shipped with the application.
  static const SubscriptionTimings standard = SubscriptionTimings();

  /// How long the first result stays alone on screen before the paywall.
  final Duration paywallDelay;

  /// How long the fake purchase takes once confirmed.
  final Duration processingDelay;

  @override
  List<Object> get props => [paywallDelay, processingDelay];
}
