import 'package:equatable/equatable.dart';
import 'package:solenn/features/account/domain/legal/legal_block.dart';

/// A legal text, as an ordered list of blocks.
class LegalDocument extends Equatable {
  /// Creates a document made of [blocks].
  const LegalDocument(this.blocks);

  /// Headings and paragraphs, in reading order.
  final List<LegalBlock> blocks;

  @override
  List<Object> get props => [blocks];
}
