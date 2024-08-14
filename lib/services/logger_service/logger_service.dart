import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web3modal_flutter/services/logger_service/i_logger_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class LoggerService implements ILoggerService {
  late Logger _logger;
  LoggerService({
    required LogLevel level,
    bool debugMode = kDebugMode,
  }) {
    _logger = Logger(
      level: level.toLevel(),
      printer: PrettyPrinter(methodCount: null),
    );
    if (debugMode) {
      Logger.addLogListener(_logListener);
    }
  }

  void _logListener(LogEvent event) {
    debugPrint('${event.message}');
    if (event.error != null) debugPrint('Exception : ${event.error}');
    if (event.stackTrace != null) {
      debugPrint('Stacktrace :\n${event.stackTrace}');
    }
  }

  @override
  void d(
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void e(
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void i(
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void t(
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  Future<void> close() async {
    try {
      Logger.removeLogListener(_logListener);
    } catch (_) {}
    return await _logger.close();
  }
}
