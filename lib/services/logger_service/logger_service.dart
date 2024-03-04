import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web3modal_flutter/services/logger_service/i_logger_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class LoggerService implements ILoggerService {
  static final _loggerController = StreamController<LogEvent>.broadcast();

  @override
  final Stream<LogEvent> logEvents = _loggerController.stream;

  @override
  void sink(LogEvent event) => _loggerController.sink.add(event);

  late Logger _logger;

  LoggerService({required LogLevel level, bool debugMode = true}) {
    _logger = Logger(
      level: level.toLevel(),
      printer: PrettyPrinter(methodCount: null),
    );
    if (kDebugMode && debugMode) {
      Logger.addLogListener(_logListener);
    }
  }

  void _logListener(LogEvent event) {
    sink(event);
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
