import 'dart:developer' as developer;

class AppLogger {
  static void d(String message) {
    developer.log(message, name: 'DEBUG');
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }
}
