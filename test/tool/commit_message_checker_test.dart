import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/commit_message_checker.dart';

void main() {
  group('checkCommitMessage', () {
    group('accepted messages', () {
      const accepted = <String>[
        'feat(calculator): add keypad',
        'chore: add repository hygiene files',
        'fix(core)!: drop the legacy theme',
        'ci(release): add release-please',
        'revert: undo the keypad change',
        'feat: 3 digits are now supported',
        'Merge branch main into feature',
        'Revert "feat: add keypad"',
        'fixup! feat: add keypad',
        'squash! feat: add keypad',
      ];

      for (final message in accepted) {
        test('should accept "$message" when it follows the rules', () {
          expect(checkCommitMessage(message), isNull);
        });
      }

      test('should ignore the body when the first line is valid', () {
        const message = 'feat: add keypad\r\n\r\nLonger body. With a period.';

        expect(checkCommitMessage(message), isNull);
      });

      test('should ignore trailing spaces when the header is valid', () {
        expect(checkCommitMessage('feat: add keypad   '), isNull);
      });

      test('should accept a 72-character subject when at the limit', () {
        final message = 'feat: ${'a' * maxSubjectLength}';

        expect(checkCommitMessage(message), isNull);
      });
    });

    group('rejected messages', () {
      const rejected = <(String, String)>[
        ('add keypad', 'type(scope): subject'),
        ('Feat: add keypad', 'type(scope): subject'),
        ('feat:add keypad', 'type(scope): subject'),
        ('', 'type(scope): subject'),
        ('wip: add keypad', 'unknown type'),
        ('feat(foo): add keypad', 'unknown scope'),
        ('feat(): add keypad', 'unknown scope'),
        ('feat: Add keypad', 'lower-case'),
        ('feat: add keypad.', 'period'),
      ];

      for (final (message, fragment) in rejected) {
        test('should reject "$message" when it breaks the rules', () {
          expect(checkCommitMessage(message), contains(fragment));
        });
      }

      test('should reject a 73-character subject when over the limit', () {
        final message = 'feat: ${'a' * (maxSubjectLength + 1)}';

        expect(checkCommitMessage(message), contains('73'));
      });
    });
  });
}
