import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An [AssetBundle] that serves texts from memory.
///
/// When [gate] is given, loading waits for it, which lets a test look at the
/// screen while an asset is still loading.
class FakeAssetBundle extends CachingAssetBundle {
  /// Creates a bundle serving [assets], keyed by asset path.
  FakeAssetBundle(this.assets, {this.gate});

  /// The served texts.
  final Map<String, String> assets;

  /// Completes when loading may proceed. `null` means no waiting.
  final Future<void>? gate;

  @override
  Future<ByteData> load(String key) async {
    await gate;
    final text = assets[key];
    if (text == null) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}
