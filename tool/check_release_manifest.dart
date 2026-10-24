import 'dart:io';

import 'src/manifest_checker.dart';

const String _defaultDirectory =
    'build/app/intermediates/merged_manifests/release';

/// Fails when the merged release manifest breaks the privacy constraints.
///
/// Usage: `dart run tool/check_release_manifest.dart [directory]`
void main(List<String> arguments) {
  final directory = Directory(
    arguments.isEmpty ? _defaultDirectory : arguments.first,
  );
  if (!directory.existsSync()) {
    stderr
      ..writeln('Directory not found: ${directory.path}')
      ..writeln('Build the release first: flutter build apk --release');
    exit(2);
  }

  final manifests = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('AndroidManifest.xml'))
      .toList();
  if (manifests.isEmpty) {
    stderr.writeln('No AndroidManifest.xml found in ${directory.path}');
    exit(2);
  }

  var failed = false;
  for (final manifest in manifests) {
    final violations = manifestViolations(manifest.readAsStringSync());
    if (violations.isEmpty) {
      stdout.writeln('OK   ${manifest.path}');
    } else {
      failed = true;
      stdout.writeln('FAIL ${manifest.path}');
      for (final violation in violations) {
        stdout.writeln('  - $violation');
      }
    }
  }
  if (failed) exit(1);
}
