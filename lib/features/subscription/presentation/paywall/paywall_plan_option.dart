import 'package:flutter/foundation.dart';

/// Display data of one plan on the paywall.
///
/// The view renders strings only. Mapping domain plans and money to these
/// strings is the job of the layer that builds the view.
@immutable
class PaywallPlanOption {
  /// Creates the display data of a plan.
  const PaywallPlanOption({
    required this.id,
    required this.title,
    required this.price,
    required this.semanticLabel,
    this.subtitle,
    this.anchorPrice,
    this.badge,
    this.dense = false,
  });

  /// Stable identifier reported when the plan is selected.
  final String id;

  /// Plan name.
  final String title;

  /// Formatted price.
  final String price;

  /// Complete spoken description, badge and anchor price included.
  final String semanticLabel;

  /// Secondary line below the title.
  final String? subtitle;

  /// Formatted reference price, drawn struck through.
  final String? anchorPrice;

  /// Uppercase badge overlapping the top edge of the card.
  final String? badge;

  /// Whether the card uses the compact layout.
  final bool dense;
}
