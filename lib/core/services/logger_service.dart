import 'package:logger/logger.dart';

class LoggerService {
  final Logger _logger;
  final String _tag;

  LoggerService(this._tag) : _logger = Logger();

  void d(String message) {
    _logger.d('[$_tag] $message');
  }

  void i(String message) {
    _logger.i('[$_tag] $message');
  }

  void w(String message) {
    _logger.w('[$_tag] $message');
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e('[$_tag] $message', error: error, stackTrace: stackTrace);
  }
}