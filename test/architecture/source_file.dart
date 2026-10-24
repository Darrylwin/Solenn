import 'dart:io';

final RegExp _directivePattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// A Dart source file, identified by its project-relative POSIX path.
class SourceFile {
  const SourceFile(this.path, this.content);

  final String path;
  final String content;

  /// Targets of every `import` and `export` directive.
  List<String> get directives => _directivePattern
      .allMatches(content)
      .map((match) => match.group(1)!)
      .toList();
}

/// Reads every Dart file under [roots] (relative to the project root).
List<SourceFile> readSources(List<String> roots) {
  final files = <SourceFile>[];
  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(
          SourceFile(
            entity.path.replaceAll(r'\', '/'),
            entity.readAsStringSync(),
          ),
        );
      }
    }
  }
  return files;
}
