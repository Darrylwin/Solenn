import 'dart:io';

import 'src/commit_message_checker.dart';

/// Validates the commit message stored in the file given as first argument
/// (the path git passes to the commit-msg hook).
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/check_commit_msg.dart <message-file>',
    );
    exit(2);
  }

  final message = File(args.first).readAsStringSync();
  final problem = checkCommitMessage(message);
  if (problem == null) {
    return;
  }

  stderr
    ..writeln('Invalid commit message: $problem')
    ..writeln()
    ..writeln('Expected: <type>[(scope)][!]: <subject>')
    ..writeln('Types: ${commitTypes.join(', ')}')
    ..writeln('Scopes: ${commitScopes.join(', ')}');
  exit(1);
}
