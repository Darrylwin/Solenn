import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/coverage_report.dart';

String _record(String path, int found, int hit) =>
    'SF:$path\nLF:$found\nLH:$hit\nend_of_record\n';

void main() {
  group('parseLcov', () {
    test('should read the line totals of every file', () {
      final files = parseLcov(
        _record('lib/a.dart', 10, 7) + _record(r'lib\b.dart', 4, 4),
      );

      expect(files.map((file) => file.path), ['lib/a.dart', 'lib/b.dart']);
      expect(files.first.found, 10);
      expect(files.first.hit, 7);
    });

    test('should return nothing for an empty report', () {
      expect(parseLcov(''), isEmpty);
    });
  });

  group('evaluate', () {
    test('should pass when thresholds are met', () {
      final report = evaluate(
        parseLcov(
          _record('lib/app/a.dart', 100, 85) +
              _record('lib/features/x/domain/b.dart', 100, 95),
        ),
      );

      expect(report.passed, isTrue);
    });

    test('should fail when overall coverage is too low', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 100, 84)));

      expect(report.passed, isFalse);
      expect(report.failures.single, contains('Overall'));
    });

    test('should fail when domain coverage is too low', () {
      final report = evaluate(
        parseLcov(
          _record('lib/app/a.dart', 1000, 1000) +
              _record('lib/features/x/domain/b.dart', 100, 94),
        ),
      );

      expect(report.failures.single, contains('Domain'));
    });

    test('should skip the domain check while there is no domain file', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 10, 10)));

      expect(report.domain, isNull);
      expect(report.passed, isTrue);
    });

    test('should ignore generated code and entry points', () {
      final report = evaluate(
        parseLcov(
          _record('lib/app/a.dart', 10, 10) +
              _record('lib/l10n/app_localizations.dart', 100, 0) +
              _record('lib/main.dart', 100, 0) +
              _record('lib/bootstrap.dart', 100, 0),
        ),
      );

      expect(report.overall.found, 10);
      expect(report.passed, isTrue);
    });

    test('should fail when nothing is measured', () {
      expect(evaluate(const []).passed, isFalse);
    });
  });

  group('renderMarkdown', () {
    test('should list failures and unloaded files', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 100, 10)));

      final markdown = renderMarkdown(report, unloaded: ['lib/app/b.dart']);

      expect(markdown, contains('FAIL: Overall'));
      expect(markdown, contains('- lib/app/b.dart'));
    });
  });
}
