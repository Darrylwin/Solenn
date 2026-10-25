import 'package:decimal/decimal.dart';
import 'package:solenn/features/calculator/domain/engine/decimal_math.dart';

/// Whether [shown] is a lie the user can believe about [truth].
///
/// It must be nonzero, in range, of the same sign and within one order of
/// magnitude. A zero truth is believably replaced by a small positive number.
bool isPlausible({required Decimal shown, required Decimal truth}) {
  if (isZero(shown) || isOutOfRange(shown)) return false;
  if (isZero(truth)) return !isNegative(shown) && leadingExponent(shown) <= 0;
  if (isNegative(shown) != isNegative(truth)) return false;
  return (leadingExponent(shown) - leadingExponent(truth)).abs() <= 1;
}
