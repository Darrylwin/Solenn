import 'package:equatable/equatable.dart';

/// A block of a legal document.
sealed class LegalBlock extends Equatable {
  /// Creates a block holding [text].
  const LegalBlock(this.text);

  /// The text of the block.
  final String text;

  @override
  List<Object> get props => [text];
}

/// A section heading.
final class LegalHeading extends LegalBlock {
  /// Creates a heading.
  const LegalHeading(super.text);
}

/// A paragraph of running text.
final class LegalParagraph extends LegalBlock {
  /// Creates a paragraph.
  const LegalParagraph(super.text);
}
