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

      expect(markdown, contains('### Line coverage: failed'));
      expect(markdown, contains('| Overall | 10.0% | 85% | FAIL |'));
      expect(markdown, contains('- Overall coverage 10.0% is below 85%.'));
      expect(markdown, contains('1 files never loaded by a test'));
      expect(markdown, contains('- `lib/app/b.dart`'));
    });

    test('should omit failures and unloaded files when there are none', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 10, 10)));

      final markdown = renderMarkdown(report);

      expect(markdown, contains('### Line coverage: passed'));
      expect(markdown, isNot(contains('Failures')));
      expect(markdown, isNot(contains('<details>')));
    });

    test('should mark the domain as not applicable without domain file', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 10, 10)));

      expect(
        renderMarkdown(report),
        contains('| Domain | n/a | 95% | N/A |'),
      );
    });
  });

  group('renderText', () {
    test('should align the table and list failures', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 100, 10)));

      final text = renderText(report);

      expect(text, contains('Line coverage: FAILED'));
      expect(text, contains('Overall'));
      expect(text, contains('10.0%'));
      expect(text, contains('FAIL'));
      expect(text, contains('  - Overall coverage 10.0% is below 85%.'));
    });

    test('should group unloaded files by directory', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 10, 10)));

      final text = renderText(
        report,
        unloaded: ['lib/app/b.dart', 'lib/app/c.dart', 'lib/core/d.dart'],
      );

      expect(text, contains('Files never loaded by a test (3)'));
      expect(text, contains('  lib/app/\n    b.dart\n    c.dart\n'));
      expect(text, contains('  lib/core/\n    d.dart\n'));
    });

    test('should report a pass without failures section', () {
      final report = evaluate(parseLcov(_record('lib/app/a.dart', 10, 10)));

      final text = renderText(report);

      expect(text, contains('Line coverage: PASSED'));
      expect(text, isNot(contains('Failures')));
    });
  });
}
