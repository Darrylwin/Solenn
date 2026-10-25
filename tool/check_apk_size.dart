import 'dart:io';

import 'src/size_budget.dart';

/// Fails when an APK is larger than its size budget.
///
/// Usage: `dart run tool/check_apk_size.dart <path/to/app.apk>`
void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln('Usage: dart run tool/check_apk_size.dart <apk>');
    exit(64);
  }

  final file = File(arguments.single);
  if (!file.existsSync()) {
    stderr.writeln('File not found: ${file.path}');
    exit(2);
  }

  final bytes = file.lengthSync();
  final line =
      '${file.uri.pathSegments.last}: ${formatMebibytes(bytes)} '
      '(budget ${formatMebibytes(maxArm64ApkBytes)})';
  stdout.writeln(line);

  final summaryPath = Platform.environment['GITHUB_STEP_SUMMARY'];
  if (summaryPath != null) {
    File(summaryPath).writeAsStringSync('- $line\n', mode: FileMode.append);
  }

  final violation = sizeViolation(bytes);
  if (violation != null) {
    stderr.writeln(violation);
    exit(1);
  }
}
