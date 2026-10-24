import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solenn/core/services/app_logger.dart';

/// Logs state changes and errors of every Cubit. Installed in debug only.
class AppBlocObserver extends BlocObserver {
  /// Creates an observer that reports to [_logger].
  const AppBlocObserver(this._logger);

  final AppLogger _logger;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.info(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} '
      '-> ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      '${bloc.runtimeType} failed',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
