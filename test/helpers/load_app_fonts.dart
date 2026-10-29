import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads every font the application declares, so that goldens draw the real
/// typeface and the real icons instead of the blocks of the default test font.
///
/// Call it once per golden test file, from `setUpAll`. It is not installed
/// globally: the other tests keep the default font, whose metrics their layout
/// assertions were written against.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;

  for (final entry in manifest) {
    final family = entry as Map<String, dynamic>;
    final loader = FontLoader(family['family'] as String);
    for (final font in family['fonts'] as List<dynamic>) {
      final asset = (font as Map<String, dynamic>)['asset'] as String;
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
