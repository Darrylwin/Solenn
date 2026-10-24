import 'package:flutter_test/flutter_test.dart';

import 'hygiene_rules.dart';
import 'source_file.dart';

void main() {
  group('hygiene of the source tree', () {
    test('should have no violation in lib and tool', () {
      final sources = readSources(['lib', 'tool']);

      expect(sources, isNotEmpty);
      expect(hygieneViolations(sources), isEmpty);
    });
  });

  group('hygiene rules', () {
    List<String> check(String path, String content) =>
        hygieneViolations([SourceFile(path, content)]);

    test('should flag a hex color outside the tokens', () {
      expect(
        check('lib/app/x.dart', 'const c = Color(0xFF000000);'),
        hasLength(1),
      );
    });

    test('should allow a hex color inside the tokens', () {
      expect(
        check(
          'lib/core/design_system/tokens/c.dart',
          'const c = Color(0xFF000000);',
        ),
        isEmpty,
      );
    });

    test('should flag a TextStyle outside the design system', () {
      expect(
        check('lib/app/x.dart', 'const s = TextStyle(fontSize: 1);'),
        hasLength(1),
      );
    });

    test('should flag a string literal passed to Text', () {
      expect(check('lib/app/x.dart', "child: Text('Hello'),"), hasLength(1));
    });

    test('should allow Text with a localized value', () {
      expect(check('lib/app/x.dart', 'child: Text(l10n.title),'), isEmpty);
    });

    test('should flag print but not debugPrint', () {
      expect(check('lib/app/x.dart', "print('x');"), hasLength(1));
      expect(check('lib/app/x.dart', "debugPrint('x');"), isEmpty);
    });

    test('should flag DateTime.now in a Cubit', () {
      expect(
        check(
          'lib/features/calculator/presentation/cubit/a_cubit.dart',
          'final now = DateTime.now();',
        ),
        hasLength(1),
      );
    });

    test('should flag Random in domain code', () {
      expect(
        check(
          'lib/features/calculator/domain/x.dart',
          'final r = Random(1);',
        ),
        hasLength(1),
      );
    });

    test('should flag Platform.isIOS', () {
      expect(
        check('lib/app/x.dart', 'if (Platform.isIOS) {}'),
        hasLength(1),
      );
    });

    test('should flag a TODO without owner and issue', () {
      expect(check('lib/app/x.dart', '// TODO fix this'), hasLength(1));
    });

    test('should accept a TODO with owner and issue', () {
      expect(
        check('lib/app/x.dart', '// TODO(darcode): split view (#12)'),
        isEmpty,
      );
    });

    test('should ignore patterns that only appear in comments', () {
      expect(
        check('lib/app/x.dart', '// Color(0xFF000000) is banned'),
        isEmpty,
      );
    });
  });
}
