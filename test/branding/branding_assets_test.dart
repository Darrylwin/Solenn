import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const String _directory = 'assets/branding';
const int _rgb = 2;
const int _rgba = 6;

typedef _PngHeader = ({int width, int height, int colorType});

// A PNG starts with an 8-byte signature, then the IHDR chunk: its length and
// type (8 bytes), the width and the height (4 bytes each), the bit depth and
// the color type.
_PngHeader _header(String name) {
  final bytes = File('$_directory/$name.png').readAsBytesSync();
  final data = ByteData.sublistView(bytes);

  expect(data.getUint32(0), 0x89504E47, reason: '$name is not a PNG');
  return (
    width: data.getUint32(16),
    height: data.getUint32(20),
    colorType: bytes[25],
  );
}

void main() {
  group('the configuration files', () {
    final reference = RegExp(r'assets/branding/[\w.-]+');

    for (final config in [
      'flutter_launcher_icons.yaml',
      'flutter_native_splash.yaml',
    ]) {
      test('$config should only name files that exist', () {
        final paths = reference
            .allMatches(File(config).readAsStringSync())
            .map((match) => match.group(0)!)
            .toSet();

        expect(paths, isNotEmpty);
        for (final path in paths) {
          expect(File(path).existsSync(), isTrue, reason: path);
        }
      });
    }
  });

  group('the source artwork', () {
    const pngs = [
      'icon-foreground',
      'icon-monochrome',
      'icon-ios',
      'icon-ios-dark',
      'icon-ios-tinted',
      'splash-mark',
    ];

    test('should give every PNG its SVG source', () {
      for (final name in pngs) {
        expect(
          File('$_directory/$name.svg').existsSync(),
          isTrue,
          reason: name,
        );
      }
    });

    test('should keep the SVG of the plain background', () {
      expect(File('$_directory/icon-background.svg').existsSync(), isTrue);
    });
  });

  group('the iOS icons', () {
    test('should be 1024 pixels square', () {
      for (final name in ['icon-ios', 'icon-ios-dark', 'icon-ios-tinted']) {
        final header = _header(name);

        expect(header.width, 1024, reason: name);
        expect(header.height, 1024, reason: name);
      }
    });

    test('should have no alpha when they carry their own background', () {
      expect(_header('icon-ios').colorType, _rgb);
      expect(_header('icon-ios-tinted').colorType, _rgb);
    });

    test('should keep the alpha of the dark variant', () {
      expect(_header('icon-ios-dark').colorType, _rgba);
    });
  });

  group('the Android layers', () {
    test('should be 1024 pixels square with a transparent background', () {
      for (final name in ['icon-foreground', 'icon-monochrome']) {
        final header = _header(name);

        expect(header.width, 1024, reason: name);
        expect(header.height, 1024, reason: name);
        expect(header.colorType, _rgba, reason: name);
      }
    });
  });

  group('the splash mark', () {
    test('should be square and transparent', () {
      final header = _header('splash-mark');

      expect(header.width, header.height);
      expect(header.width, 1152);
      expect(header.colorType, _rgba);
    });
  });
}
