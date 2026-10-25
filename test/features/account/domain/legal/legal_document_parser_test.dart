import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/account/domain/legal/legal_block.dart';
import 'package:solenn/features/account/domain/legal/legal_document.dart';
import 'package:solenn/features/account/domain/legal/legal_document_parser.dart';

void main() {
  const parser = LegalDocumentParser();

  group('LegalDocumentParser', () {
    test('should parse a heading followed by a paragraph', () {
      final document = parser.parse('# Title\n\nSome text.');

      expect(
        document,
        const LegalDocument([
          LegalHeading('Title'),
          LegalParagraph('Some text.'),
        ]),
      );
    });

    test('should join consecutive lines into one paragraph', () {
      final document = parser.parse('First line\nsecond line\n\nNext.');

      expect(document.blocks, const [
        LegalParagraph('First line second line'),
        LegalParagraph('Next.'),
      ]);
    });

    test('should end a paragraph at a heading without a blank line', () {
      final document = parser.parse('Text\n# Heading\nMore');

      expect(document.blocks, const [
        LegalParagraph('Text'),
        LegalHeading('Heading'),
        LegalParagraph('More'),
      ]);
    });

    test('should accept Windows line endings', () {
      final document = parser.parse('# Title\r\n\r\nText\r\n');

      expect(document.blocks, const [
        LegalHeading('Title'),
        LegalParagraph('Text'),
      ]);
    });

    test('should ignore extra blank lines', () {
      final document = parser.parse('\n\n# A\n\n\n\nB\n\n');

      expect(document.blocks, const [LegalHeading('A'), LegalParagraph('B')]);
    });

    test('should return no block for an empty source', () {
      expect(parser.parse('').blocks, isEmpty);
      expect(parser.parse('  \n \n').blocks, isEmpty);
    });

    test('should not let callers modify the result', () {
      final document = parser.parse('# A');

      expect(
        () => document.blocks.add(const LegalParagraph('x')),
        throwsUnsupportedError,
      );
    });
  });

  group('bundled legal documents', () {
    for (final name in ['terms', 'privacy']) {
      test('$name should be a well-formed document', () {
        final source = File('assets/legal/$name.txt').readAsStringSync();

        final blocks = parser.parse(source).blocks;

        expect(
          blocks.whereType<LegalHeading>().length,
          greaterThanOrEqualTo(3),
        );
        expect(blocks.first, isA<LegalHeading>());
        for (var index = 0; index < blocks.length; index++) {
          if (blocks[index] is LegalHeading) {
            expect(
              index + 1,
              lessThan(blocks.length),
              reason: 'trailing heading',
            );
            expect(blocks[index + 1], isA<LegalParagraph>());
          }
        }
      });
    }

    test('should be registered as assets', () {
      expect(
        File('pubspec.yaml').readAsStringSync(),
        contains('assets/legal/'),
      );
    });
  });
}
