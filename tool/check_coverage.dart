import 'dart:io';

import 'src/coverage_report.dart';

/// Fails when line coverage is below the thresholds of the specification.
///
/// Usage: `dart run tool/check_coverage.dart [path/to/lcov.info]`
void main(List<String> arguments) {
  final reportFile = File(
    arguments.isEmpty ? 'coverage/lcov.info' : arguments.first,
  );
  if (!reportFile.existsSync()) {
    stderr.writeln('Coverage report not found: ${reportFile.path}');
    exit(2);
  }

  final files = parseLcov(reportFile.readAsStringSync());
  final report = evaluate(files);
  final unloaded = _unloadedFiles(files);

  stdout.writeln(renderText(report, unloaded: unloaded));

  final summaryPath = Platform.environment['GITHUB_STEP_SUMMARY'];
  if (summaryPath != null) {
    File(summaryPath).writeAsStringSync(
      '${renderMarkdown(report, unloaded: unloaded)}\n',
      mode: FileMode.append,
    );
  }
  if (!report.passed) exit(1);
}

/// Measured sources that no test imports. Such files are absent from the
/// report and would otherwise silently escape the thresholds.
List<String> _unloadedFiles(List<FileCoverage> files) {
  final loaded = files.map((file) => file.path).toSet();
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => file.path.replaceAll(r'\', '/'))
      .where((path) => path.endsWith('.dart'))
      .where((path) => isMeasured(path) && !loaded.contains(path))
      .toList()
    ..sort();
}
