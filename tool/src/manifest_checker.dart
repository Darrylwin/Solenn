// Permissions injected by AndroidX itself. They are scoped to the app's own
// package and grant nothing on the device.
const List<String> _allowedPermissionSuffixes = [
  '.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION',
];

final RegExp _comment = RegExp(r'<!--[\s\S]*?-->');
final RegExp _permission = RegExp(
  r'<uses-permission(?:-sdk-23)?\b[^>]*?android:name="([^"]+)"',
);

/// Rule violations found in a merged release `AndroidManifest.xml`.
///
/// Enforces constraint C2 of the specification: the app declares no
/// permission (INTERNET included) and opts out of cloud backup.
List<String> manifestViolations(String manifest) {
  final xml = manifest.replaceAll(_comment, '');
  final violations = <String>[];

  for (final match in _permission.allMatches(xml)) {
    final name = match.group(1)!;
    if (!_allowedPermissionSuffixes.any(name.endsWith)) {
      violations.add('Forbidden permission: $name');
    }
  }
  if (!xml.contains('android:allowBackup="false"')) {
    violations.add('android:allowBackup must be "false".');
  }
  return violations;
}
