/// Minimum overall line coverage (specification section 16.4).
///
/// Thresholds may only be raised; lowering one requires an ADR.
const double minimumOverallCoverage = 85;

/// Minimum line coverage across every `domain/` directory.
const double minimumDomainCoverage = 95;

const String _generatedDirectory = 'lib/l10n/';

// Entry points are exercised by integration tests instead of unit tests.
const Set<String> _entryPoints = {'lib/main.dart', 'lib/bootstrap.dart'};

/// Line coverage of one source file, as recorded in an lcov report.
class FileCoverage {
  /// Creates the coverage of the file at [path].
  const FileCoverage({
    required this.path,
    required this.found,
    required this.hit,
  });

  /// Project-relative POSIX path.
  final String path;

  /// Number of executable lines.
  final int found;

  /// Number of executed lines.
  final int hit;
}

/// Parses an lcov trace file.
List<FileCoverage> parseLcov(String content) {
  final files = <FileCoverage>[];
  String? path;
  var found = 0;
  var hit = 0;

  for (final raw in content.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('SF:')) {
      path = line.substring(3).replaceAll(r'\', '/');
      found = 0;
      hit = 0;
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && path != null) {
      files.add(FileCoverage(path: path, found: found, hit: hit));
      path = null;
    }
  }
  return files;
}

/// Whether [path] counts towards the thresholds.
bool isMeasured(String path) =>
    path.startsWith('lib/') &&
    !path.startsWith(_generatedDirectory) &&
    !_entryPoints.contains(path);

/// Whether [path] belongs to a feature's domain layer.
bool isDomain(String path) =>
    path.startsWith('lib/features/') && path.contains('/domain/');

/// Aggregated line counts.
class CoverageSummary {
  /// Creates a summary from raw counts.
  const CoverageSummary({required this.found, required this.hit});

  /// Number of executable lines.
  final int found;

  /// Number of executed lines.
  final int hit;

  /// Coverage in percent; a scope without executable lines counts as 100.
  double get percent => found == 0 ? 100 : hit * 100 / found;
}

/// Outcome of checking a report against the thresholds.
class CoverageReport {
  /// Creates a report.
  const CoverageReport({
    required this.overall,
    required this.domain,
    required this.failures,
  });

  /// Coverage of every measured file.
  final CoverageSummary overall;

  /// Coverage of domain files, or `null` while there are none.
  final CoverageSummary? domain;

  /// Human-readable threshold violations.
  final List<String> failures;

  /// Whether every threshold is met.
  bool get passed => failures.isEmpty;
}

CoverageSummary _summarize(Iterable<FileCoverage> files) => CoverageSummary(
  found: files.fold(0, (sum, file) => sum + file.found),
  hit: files.fold(0, (sum, file) => sum + file.hit),
);

String _format(double value) => value.toStringAsFixed(1);

/// Checks [files] against the coverage thresholds.
CoverageReport evaluate(Iterable<FileCoverage> files) {
  final measured = files.where((file) => isMeasured(file.path)).toList();
  final overall = _summarize(measured);
  final domainFiles = measured.where((file) => isDomain(file.path)).toList();
  final domain = domainFiles.isEmpty ? null : _summarize(domainFiles);

  final failures = <String>[];
  if (measured.isEmpty) {
    failures.add('The report contains no measured source file.');
  } else if (overall.percent < minimumOverallCoverage) {
    failures.add(
      'Overall coverage ${_format(overall.percent)}% is below '
      '${minimumOverallCoverage.toStringAsFixed(0)}%.',
    );
  }
  if (domain != null && domain.percent < minimumDomainCoverage) {
    failures.add(
      'Domain coverage ${_format(domain.percent)}% is below '
      '${minimumDomainCoverage.toStringAsFixed(0)}%.',
    );
  }
  return CoverageReport(overall: overall, domain: domain, failures: failures);
}

typedef _Row = ({String scope, String coverage, String minimum, bool? passed});

List<_Row> _rows(CoverageReport report) {
  final domain = report.domain;
  return [
    (
      scope: 'Overall',
      coverage: '${_format(report.overall.percent)}%',
      minimum: '${minimumOverallCoverage.toStringAsFixed(0)}%',
      passed: report.overall.percent >= minimumOverallCoverage,
    ),
    (
      scope: 'Domain',
      coverage: domain == null ? 'n/a' : '${_format(domain.percent)}%',
      minimum: '${minimumDomainCoverage.toStringAsFixed(0)}%',
      passed: domain == null ? null : domain.percent >= minimumDomainCoverage,
    ),
  ];
}

String _status(bool? passed) => switch (passed) {
  null => 'N/A',
  true => 'PASS',
  false => 'FAIL',
};

/// Groups [paths] by directory, keeping the input order.
Map<String, List<String>> _byDirectory(List<String> paths) {
  final groups = <String, List<String>>{};
  for (final path in paths) {
    final slash = path.lastIndexOf('/');
    groups
        .putIfAbsent(path.substring(0, slash + 1), () => [])
        .add(path.substring(slash + 1));
  }
  return groups;
}

/// Renders [report] as aligned plain text for the console.
String renderText(
  CoverageReport report, {
  List<String> unloaded = const [],
}) {
  final header = ['Scope', 'Coverage', 'Minimum', 'Status'];
  final body = [
    for (final row in _rows(report))
      [row.scope, row.coverage, row.minimum, _status(row.passed)],
  ];
  final widths = [
    for (var i = 0; i < header.length; i++)
      [header, ...body].fold(0, (w, r) => r[i].length > w ? r[i].length : w),
  ];

  String line(List<String> cells) => [
    cells[0].padRight(widths[0]),
    cells[1].padLeft(widths[1]),
    cells[2].padLeft(widths[2]),
    cells[3].padRight(widths[3]),
  ].join('   ');

  final rule = widths.map((width) => '-' * width).join('   ');

  final buffer = StringBuffer()
    ..writeln('Line coverage: ${report.passed ? 'PASSED' : 'FAILED'}')
    ..writeln()
    ..writeln(line(header))
    ..writeln(rule);
  body.map(line).forEach(buffer.writeln);

  if (report.failures.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Failures');
    for (final failure in report.failures) {
      buffer.writeln('  - $failure');
    }
  }
  if (unloaded.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(
        'Files never loaded by a test (${unloaded.length}), '
        'absent from the report',
      );
    _byDirectory(unloaded).forEach((directory, names) {
      buffer.writeln('  $directory');
      for (final name in names) {
        buffer.writeln('    $name');
      }
    });
  }
  return buffer.toString();
}

/// Renders [report] as Markdown for the GitHub job summary.
String renderMarkdown(
  CoverageReport report, {
  List<String> unloaded = const [],
}) {
  final buffer = StringBuffer()
    ..writeln('### Line coverage: ${report.passed ? 'passed' : 'failed'}')
    ..writeln()
    ..writeln('| Scope | Coverage | Minimum | Status |')
    ..writeln('|:--|--:|--:|:-:|');
  for (final row in _rows(report)) {
    buffer.writeln(
      '| ${row.scope} | ${row.coverage} | ${row.minimum} '
      '| ${_status(row.passed)} |',
    );
  }

  if (report.failures.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('**Failures**')
      ..writeln();
    for (final failure in report.failures) {
      buffer.writeln('- $failure');
    }
  }
  if (unloaded.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('<details>')
      ..writeln(
        '<summary>${unloaded.length} files never loaded by a test '
        '(absent from the report)</summary>',
      )
      ..writeln();
    for (final path in unloaded) {
      buffer.writeln('- `$path`');
    }
    buffer
      ..writeln()
      ..writeln('</details>');
  }
  return buffer.toString();
}
