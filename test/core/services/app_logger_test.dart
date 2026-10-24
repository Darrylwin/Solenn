import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/services/app_logger.dart';

void main() {
  test('should accept every severity without throwing', () {
    const logger = AppLogger();

    expect(
      () {
        logger
          ..info('info')
          ..warning('warning', error: StateError('warning'))
          ..error('error', stackTrace: StackTrace.current);
      },
      returnsNormally,
    );
  });
}
