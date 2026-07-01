import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'logger.dart';

class SentryBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.e('Bloc Error in ${bloc.runtimeType}: $error', error, stackTrace);
    
    // Capture the exception with extra context about which BLoC generated the error
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('bloc_type', bloc.runtimeType.toString());
        scope.setContexts('bloc', {
          'state': bloc.state.toString(),
        });
      },
    );
  }
}
