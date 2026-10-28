import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/subscription/domain/flow/dismiss_reason.dart';
import 'package:solenn/features/subscription/domain/flow/subscription_timings.dart';
import 'package:solenn/features/subscription/domain/flow/unlock_source.dart';
import 'package:solenn/features/subscription/domain/pricing/subscription_plan.dart';

void main() {
  group('DismissReason', () {
    test('should cover every way of leaving the paywall', () {
      expect(DismissReason.values.toSet(), {
        DismissReason.closeButton,
        DismissReason.declined,
        DismissReason.systemBack,
      });
    });
  });

  group('UnlockSource', () {
    test('should compare purchases by plan', () {
      expect(
        const Purchased(SubscriptionPlan.annual),
        const Purchased(SubscriptionPlan.annual),
      );
      expect(
        const Purchased(SubscriptionPlan.annual),
        isNot(const Purchased(SubscriptionPlan.monthly)),
      );
    });

    test('should compare dismissals by reason', () {
      expect(
        const Dismissed(DismissReason.declined),
        const Dismissed(DismissReason.declined),
      );
      expect(
        const Dismissed(DismissReason.declined),
        isNot(const Dismissed(DismissReason.systemBack)),
      );
    });

    test('should treat every restoration alike', () {
      expect(const Restored(), const Restored());
    });

    test('should tell the three sources apart', () {
      final sources = <UnlockSource>{
        const Purchased(SubscriptionPlan.annual),
        const Dismissed(DismissReason.closeButton),
        const Restored(),
      };

      expect(sources, hasLength(3));
    });

    test('should be matched exhaustively', () {
      String describe(UnlockSource source) => switch (source) {
        Purchased(:final plan) => 'purchased ${plan.name}',
        Dismissed(:final reason) => 'dismissed ${reason.name}',
        Restored() => 'restored',
      };

      expect(describe(const Restored()), 'restored');
      expect(
        describe(const Purchased(SubscriptionPlan.monthly)),
        'purchased monthly',
      );
    });
  });

  group('SubscriptionTimings', () {
    test('should wait two and a half seconds before the paywall', () {
      expect(
        SubscriptionTimings.standard.paywallDelay,
        const Duration(milliseconds: 2500),
      );
    });

    test('should take one and a fifth seconds to process a purchase', () {
      expect(
        SubscriptionTimings.standard.processingDelay,
        const Duration(milliseconds: 1200),
      );
    });

    test('should accept shorter delays', () {
      const timings = SubscriptionTimings(
        paywallDelay: Duration(milliseconds: 10),
        processingDelay: Duration.zero,
      );

      expect(timings.paywallDelay, const Duration(milliseconds: 10));
      expect(timings.processingDelay, Duration.zero);
    });

    test('should compare timings by value', () {
      expect(SubscriptionTimings.standard, SubscriptionTimings.standard);
      expect(
        const SubscriptionTimings(paywallDelay: Duration.zero),
        isNot(SubscriptionTimings.standard),
      );
    });
  });
}
