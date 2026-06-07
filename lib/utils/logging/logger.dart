import 'package:logger/logger.dart';

/// A lightweight wrapper around the [Logger] package that provides
/// a consistent logging interface across the EdoxLibrary application.
///
/// Usage:
/// ```dart
/// XLoggerHelper.info('User logged in');
/// XLoggerHelper.error('Failed to fetch data', error: e, stackTrace: st);
/// ```
class XLoggerHelper {
  XLoggerHelper._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Logs a debug-level message. Use for development-only information.
  static void debug(String message) {
    _logger.d(message);
  }

  /// Logs an info-level message. Use for general informational events.
  static void info(String message) {
    _logger.i(message);
  }

  /// Logs a warning-level message. Use for potentially harmful situations.
  static void warning(String message) {
    _logger.w(message);
  }

  /// Logs an error-level message with an optional [error] object and [stackTrace].
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
