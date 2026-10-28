/// How often a plan is billed.
enum BillingPeriod {
  /// Billed every month.
  monthly(1),

  /// Billed every year.
  yearly(12)
  ;

  const BillingPeriod(this.months);

  /// Number of months one payment covers.
  final int months;
}
