import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/core/services/app_bloc_observer.dart';
import 'package:solenn/core/services/app_logger.dart';

class _RecordingLogger extends AppLogger {
  _RecordingLogger();

  final List<String> infos = [];
  final List<String> errors = [];

  @override
  void info(String message) => infos.add(message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      errors.add(message);
}

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);

  void increment() => emit(state + 1);

  void fail() => addError(StateError('boom'));
}

void main() {
  late BlocObserver previous;
  late _RecordingLogger logger;
  late _CounterCubit cubit;

  setUp(() {
    previous = Bloc.observer;
    logger = _RecordingLogger();
    Bloc.observer = AppBlocObserver(logger);
    cubit = _CounterCubit();
  });

  tearDown(() async {
    await cubit.close();
    Bloc.observer = previous;
  });

  test('should log state changes', () {
    cubit.increment();

    expect(logger.infos, ['_CounterCubit: int -> int']);
  });

  test('should log errors', () {
    cubit.fail();

    expect(logger.errors, ['_CounterCubit failed']);
  });
}
