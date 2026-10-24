import 'source_file.dart';

class _PatternRule {
  _PatternRule({
    required this.message,
    required this.pattern,
    required this.appliesTo,
    this.includeComments = false,
  });

  final String message;
  final RegExp pattern;
  final bool Function(String path) appliesTo;
  final bool includeComments;
}

bool _inLib(String path) => path.startsWith('lib/');

bool _isDomainOrCubit(String path) =>
    path.startsWith('lib/features/') &&
    (path.contains('/domain/') || path.endsWith('_cubit.dart'));

final List<_PatternRule> _rules = [
  _PatternRule(
    message: 'hex color literal outside the design tokens',
    pattern: RegExp(r'Color\(\s*0x'),
    appliesTo: (path) =>
        _inLib(path) && !path.startsWith('lib/core/design_system/tokens/'),
  ),
  _PatternRule(
    message: 'TextStyle outside the design system',
    pattern: RegExp(r'\bTextStyle\('),
    appliesTo: (path) =>
        _inLib(path) && !path.startsWith('lib/core/design_system/'),
  ),
  _PatternRule(
    message: 'string literal passed to Text; use localized strings',
    pattern: RegExp('\\bText\\(\\s*[\'"]'),
    appliesTo: (path) => _inLib(path) && !path.startsWith('lib/l10n/'),
  ),
  _PatternRule(
    message: 'print is forbidden; use AppLogger',
    pattern: RegExp(r'(?<![\w.])print\('),
    appliesTo: _inLib,
  ),
  _PatternRule(
    message: 'DateTime.now() or Random() in domain or Cubit; inject instead',
    pattern: RegExp(r'DateTime\.now\(\)|\bRandom\('),
    appliesTo: _isDomainOrCubit,
  ),
  _PatternRule(
    message: 'Platform.isIOS/isAndroid; use Theme.of(context).platform',
    pattern: RegExp(r'Platform\.is(?:IOS|Android)\b'),
    appliesTo: _inLib,
  ),
  _PatternRule(
    message: 'TODO without owner and issue: // TODO(owner): text (#123)',
    pattern: RegExp(r'//\s*TODO(?!\([\w.-]+\):[^\n]*\(#\d+\))'),
    appliesTo: (path) => _inLib(path) || path.startsWith('tool/'),
    includeComments: true,
  ),
];

final RegExp _lineComment = RegExp(r'//[^\n]*');
final RegExp _blockComment = RegExp(r'/\*[\s\S]*?\*/');

String _withoutComments(String content) =>
    content.replaceAll(_blockComment, '').replaceAll(_lineComment, '');

/// Repository hygiene rules (specification section 15.3).
List<String> hygieneViolations(Iterable<SourceFile> files) {
  final violations = <String>[];
  for (final file in files) {
    final code = _withoutComments(file.content);
    for (final rule in _rules.where((rule) => rule.appliesTo(file.path))) {
      final subject = rule.includeComments ? file.content : code;
      if (rule.pattern.hasMatch(subject)) {
        violations.add('${file.path}: ${rule.message}');
      }
    }
  }
  return violations;
}
