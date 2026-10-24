import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/manifest_checker.dart';

String _manifest({String permissions = '', String backup = 'false'}) =>
    '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    $permissions
    <application android:allowBackup="$backup" />
</manifest>
''';

void main() {
  group('manifestViolations', () {
    test('should accept a manifest without permission', () {
      expect(manifestViolations(_manifest()), isEmpty);
    });

    test('should accept the AndroidX internal permission', () {
      final manifest = _manifest(
        permissions:
            '<uses-permission android:name='
            '"com.darcode.solenn.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION" />',
      );

      expect(manifestViolations(manifest), isEmpty);
    });

    test('should flag the INTERNET permission', () {
      final manifest = _manifest(
        permissions:
            '<uses-permission android:name="android.permission.INTERNET" />',
      );

      expect(
        manifestViolations(manifest).single,
        contains('android.permission.INTERNET'),
      );
    });

    test('should flag a permission declared with extra attributes', () {
      final manifest = _manifest(
        permissions:
            '<uses-permission-sdk-23 android:maxSdkVersion="30" '
            'android:name="android.permission.CAMERA" />',
      );

      expect(manifestViolations(manifest), hasLength(1));
    });

    test('should ignore permissions mentioned only in comments', () {
      final manifest = _manifest(
        permissions: '<!-- <uses-permission android:name="x.INTERNET" /> -->',
      );

      expect(manifestViolations(manifest), isEmpty);
    });

    test('should flag a manifest that allows backups', () {
      expect(manifestViolations(_manifest(backup: 'true')), hasLength(1));
    });
  });
}
