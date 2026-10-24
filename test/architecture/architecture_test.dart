import 'package:flutter_test/flutter_test.dart';

import 'architecture_rules.dart';
import 'source_file.dart';

void main() {
  group('architecture of the source tree', () {
    final sources = readSources(['lib']);

    test('should find the application sources', () {
      expect(sources, isNotEmpty);
    });

    test('should keep domain layers pure', () {
      expect(domainPurityViolations(sources), isEmpty);
    });

    test('should keep features independent from each other', () {
      expect(featureIsolationViolations(sources), isEmpty);
    });

    test('should keep core independent from features and app', () {
      expect(coreIndependenceViolations(sources), isEmpty);
    });

    test('should use package imports only', () {
      expect(packageImportViolations(sources), isEmpty);
    });
  });

  group('architecture rules', () {
    test('should flag a domain file importing Flutter', () {
      const file = SourceFile(
        'lib/features/calculator/domain/engine.dart',
        "import 'package:flutter/material.dart';",
      );

      expect(domainPurityViolations([file]), hasLength(1));
    });

    test('should accept a domain file importing allowed libraries', () {
      const file = SourceFile(
        'lib/features/calculator/domain/engine.dart',
        "import 'dart:math';\n"
            "import 'package:decimal/decimal.dart';\n"
            "import 'package:solenn/features/calculator/domain/x.dart';",
      );

      expect(domainPurityViolations([file]), isEmpty);
    });

    test('should flag a domain file importing another feature', () {
      const file = SourceFile(
        'lib/features/calculator/domain/engine.dart',
        "import 'package:solenn/features/subscription/domain/plan.dart';",
      );

      expect(domainPurityViolations([file]), hasLength(1));
    });

    test('should flag a feature importing another feature', () {
      const file = SourceFile(
        'lib/features/calculator/presentation/page.dart',
        "import 'package:solenn/features/subscription/domain/plan.dart';",
      );

      expect(featureIsolationViolations([file]), hasLength(1));
    });

    test('should flag a feature importing the app layer', () {
      const file = SourceFile(
        'lib/features/calculator/presentation/page.dart',
        "import 'package:solenn/app/app.dart';",
      );

      expect(featureIsolationViolations([file]), hasLength(1));
    });

    test('should flag core importing a feature', () {
      const file = SourceFile(
        'lib/core/platform/x.dart',
        "import 'package:solenn/features/calculator/domain/y.dart';",
      );

      expect(coreIndependenceViolations([file]), hasLength(1));
    });

    test('should flag a relative import', () {
      const file = SourceFile('lib/app/x.dart', "import 'y.dart';");

      expect(packageImportViolations([file]), hasLength(1));
    });
  });
}
