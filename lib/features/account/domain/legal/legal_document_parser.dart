import 'package:solenn/features/account/domain/legal/legal_block.dart';
import 'package:solenn/features/account/domain/legal/legal_document.dart';

final RegExp _heading = RegExp(r'^#\s+(.+)$');

/// Parses the bundled legal text format.
///
/// A line starting with `# ` is a heading. Consecutive text lines form one
/// paragraph, and a blank line ends it. Keeping the format this small avoids
/// a Markdown dependency for two static documents.
class LegalDocumentParser {
  /// Creates a parser.
  const LegalDocumentParser();

  /// Parses [source] into a document.
  LegalDocument parse(String source) {
    final blocks = <LegalBlock>[];
    final paragraph = <String>[];

    void endParagraph() {
      if (paragraph.isEmpty) return;
      blocks.add(LegalParagraph(paragraph.join(' ')));
      paragraph.clear();
    }

    for (final rawLine in source.split('\n')) {
      // Trimming also removes the carriage return of CRLF files.
      final line = rawLine.trim();
      if (line.isEmpty) {
        endParagraph();
        continue;
      }
      final heading = _heading.firstMatch(line);
      if (heading == null) {
        paragraph.add(line);
      } else {
        endParagraph();
        blocks.add(LegalHeading(heading.group(1)!.trim()));
      }
    }
    endParagraph();

    return LegalDocument(List.unmodifiable(blocks));
  }
}
