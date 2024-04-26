import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web3modal_flutter/services/logger_service/i_logger_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class LoggerService implements ILoggerService {
  late Logger _logger;
  late String _projectId;
  LoggerService({
    required LogLevel level,
    required String projectId,
    bool debugMode = true,
  }) {
    _projectId = projectId;
    _logger = Logger(
      level: level.toLevel(),
      printer: PrettyPrinter(methodCount: null),
    );
    if (debugMode && level == LogLevel.error) {
      Logger.addLogListener(_logListener);
    }
  }

  void _logListener(LogEvent event) {
    debugPrint('${event.message}');
  }

  @override
  void p(
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // TODO [LoggerService] fix this
    if (_projectId == 'cad4956f31a5e40a00b62865b030c6f8') {
      _logger.i(message, time: time, error: error, stackTrace: stackTrace);
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
  void f(
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, time: time, error: error, stackTrace: stackTrace);
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
  void log(
    Level level,
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.log(level, message,
        time: time, error: error, stackTrace: stackTrace);
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
  void w(
    message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  Future<void> close() async {
    Logger.removeLogListener(_logListener);
    return await _logger.close();
  }
}
