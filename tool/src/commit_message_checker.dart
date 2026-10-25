/// Allowed Conventional Commit types.
const commitTypes = <String>[
  'feat',
  'fix',
  'perf',
  'refactor',
  'docs',
  'test',
  'build',
  'ci',
  'chore',
  'revert',
];

/// Allowed Conventional Commit scopes (a scope is optional).
const commitScopes = <String>[
  'calculator',
  'subscription',
  'account',
  'core',
  'design-system',
  'platform',
  'app',
  'l10n',
  'android',
  'ios',
  'deps',
  'release',
  'docs',
  'ci',
];

/// Maximum length of the subject (the text after `type(scope): `).
const maxSubjectLength = 72;

final _header = RegExp(
  r'^(?<type>[a-z]+)(\((?<scope>[^)]*)\))?(?<bang>!)?: (?<subject>.+)$',
);

/// Returns a description of the first problem found in [message], or `null`
/// when its first line follows the project's Conventional Commits rules.
///
/// Merge commits and git-generated `Revert "..."`, `fixup!` and `squash!`
/// commits are accepted as-is.
String? checkCommitMessage(String message) {
  final firstLine = message.split(RegExp(r'\r?\n')).first.trimRight();

  if (firstLine.startsWith('Merge ') ||
      firstLine.startsWith('Revert "') ||
      firstLine.startsWith('fixup! ') ||
      firstLine.startsWith('squash! ')) {
    return null;
  }

  final match = _header.firstMatch(firstLine);
  if (match == null) {
    return 'the first line must look like "type(scope): subject".';
  }

  final type = match.namedGroup('type')!;
  if (!commitTypes.contains(type)) {
    return 'unknown type "$type".';
  }

  final scope = match.namedGroup('scope');
  if (scope != null && !commitScopes.contains(scope)) {
    return 'unknown scope "$scope".';
  }

  final subject = match.namedGroup('subject')!;
  if (subject.length > maxSubjectLength) {
    return 'the subject is ${subject.length} characters long '
        '(maximum $maxSubjectLength).';
  }
  if (subject.endsWith('.')) {
    return 'the subject must not end with a period.';
  }
  if (subject[0] != subject[0].toLowerCase()) {
    return 'the subject must start with a lower-case letter.';
  }

  return null;
}
