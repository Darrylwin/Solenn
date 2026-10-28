import 'package:equatable/equatable.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';

/// Where the user is in the subscription flow of the current launch.
///
/// The flow always moves forward and ends in [Active]. Nothing is persisted
/// (constraint C3): a new launch starts again at [Locked].
sealed class SubscriptionState extends Equatable {
  /// Creates a state.
  const SubscriptionState();

  /// Whether the app is unlocked for the rest of the launch.
  bool get isUnlocked => false;

  @override
  List<Object> get props => const [];
}

/// Nothing happened yet: no calculation was made.
final class Locked extends SubscriptionState {
  /// Creates the initial state.
  const Locked();
}

/// The first result is on screen and the paywall is about to appear.
final class PaywallPending extends SubscriptionState {
  /// Creates the state.
  const PaywallPending();
}

/// The paywall is on screen.
final class PaywallVisible extends SubscriptionState {
  /// Creates the state with [selectedPlan] selected.
  const PaywallVisible({required this.selectedPlan});

  /// The plan the call to action would buy.
  final SubscriptionPlan selectedPlan;

  @override
  List<Object> get props => [selectedPlan];
}

/// The purchase confirmation of [plan] is on screen.
final class CheckoutVisible extends SubscriptionState {
  /// Creates the state for [plan].
  const CheckoutVisible({required this.plan});

  /// The plan awaiting confirmation.
  final SubscriptionPlan plan;

  @override
  List<Object> get props => [plan];
}

/// The purchase of [plan] was confirmed and is being "processed".
final class Processing extends SubscriptionState {
  /// Creates the state for [plan].
  const Processing({required this.plan});

  /// The plan being purchased.
  final SubscriptionPlan plan;

  @override
  List<Object> get props => [plan];
}

/// The app is unlocked. This state is final for the launch.
final class Active extends SubscriptionState {
  /// Creates the state, unlocked for [source].
  const Active(this.source);

  /// Why the app is unlocked.
  final UnlockSource source;

  @override
  bool get isUnlocked => true;

  @override
  List<Object> get props => [source];
}
