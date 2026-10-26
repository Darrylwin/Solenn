import 'package:equatable/equatable.dart';
import 'package:solenn/features/calculator/domain/input/input_token.dart';

/// A calculation kept in the session history.
///
/// It stores what the user saw, never the truth: [result] is the value that
/// was displayed, lie included.
class HistoryEntry extends Equatable {
  /// Creates an entry for the calculation made of [tokens].
  const HistoryEntry({required this.tokens, required this.result});

  /// The expression that was evaluated.
  final List<InputToken> tokens;

  /// Canonical text of the displayed result.
  final String result;

  @override
  List<Object> get props => [tokens, result];
}
