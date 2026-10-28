import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final copied = <String?>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    copied.clear();
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add(
          (call.arguments as Map<Object?, Object?>)['text'] as String?,
        );
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('should put the text on the system clipboard', () async {
    await const SystemClipboardService().copy('24,820');

    expect(copied, ['24,820']);
  });

  test('should keep the text exactly as given', () async {
    await const SystemClipboardService().copy('1.23456789e+9');

    expect(copied, ['1.23456789e+9']);
  });
}
