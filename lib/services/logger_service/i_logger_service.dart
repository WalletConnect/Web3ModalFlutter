import 'package:web3modal_flutter/web3modal_flutter.dart';

abstract class ILoggerService {
  /// Log a message at level [Level.trace].
  void t(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at level [Level.debug].
  void d(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at level [Level.info].
  void i(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at level [Level.warning].
  void w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at level [Level.error].
  void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at level [Level.fatal].
  void f(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message with [level].
  void log(
    Level level,
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at level private.
  void p(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Closes the logger and releases all resources.
  Future<void> close();
}
