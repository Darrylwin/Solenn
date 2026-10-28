import 'package:equatable/equatable.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';

/// Why the app is unlocked for this launch.
sealed class UnlockSource extends Equatable {
  /// Creates a source.
  const UnlockSource();
}

/// The user went through the purchase confirmation of [plan].
final class Purchased extends UnlockSource {
  /// Creates a purchase of [plan].
  const Purchased(this.plan);

  /// The plan that was confirmed.
  final SubscriptionPlan plan;

  @override
  List<Object> get props => [plan];
}

/// The user left the paywall without choosing a plan.
final class Dismissed extends UnlockSource {
  /// Creates a dismissal for [reason].
  const Dismissed(this.reason);

  /// How the paywall was left.
  final DismissReason reason;

  @override
  List<Object> get props => [reason];
}

/// The user asked to restore purchases.
final class Restored extends UnlockSource {
  /// Creates a restoration.
  const Restored();

  @override
  List<Object> get props => const [];
}
