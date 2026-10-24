import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/platform/platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final requested = <Object?>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    requested.clear();
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        requested.add(call.arguments);
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('should request a selection click', () async {
    const SystemHapticsService().selection();
    await pumpEventQueue();

    expect(requested, ['HapticFeedbackType.selectionClick']);
  });

  test('should request a light impact', () async {
    const SystemHapticsService().light();
    await pumpEventQueue();

    expect(requested, ['HapticFeedbackType.lightImpact']);
  });

  test('should request a medium impact', () async {
    const SystemHapticsService().medium();
    await pumpEventQueue();

    expect(requested, ['HapticFeedbackType.mediumImpact']);
  });
}
