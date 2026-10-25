/// Size budget of the arm64 release APK (specification section 6.6).
///
/// Raising it is a deliberate decision, reviewed like any other threshold.
const int maxArm64ApkBytes = 25 * 1024 * 1024;

const int _bytesPerMebibyte = 1024 * 1024;

/// Formats [bytes] in mebibytes with one decimal.
String formatMebibytes(int bytes) =>
    '${(bytes / _bytesPerMebibyte).toStringAsFixed(1)} MiB';

/// Returns a message when [bytes] exceeds [budget], or `null` when it fits.
String? sizeViolation(int bytes, {int budget = maxArm64ApkBytes}) {
  if (bytes <= budget) return null;
  return '${formatMebibytes(bytes)} exceeds the budget of '
      '${formatMebibytes(budget)}.';
}
