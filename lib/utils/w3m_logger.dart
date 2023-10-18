import 'package:logger/logger.dart';

enum W3MLogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
  nothing;

  Level toLevel() {
    switch (this) {
      case W3MLogLevel.verbose:
        return Level.trace;
      case W3MLogLevel.debug:
        return Level.debug;
      case W3MLogLevel.info:
        return Level.info;
      case W3MLogLevel.warning:
        return Level.warning;
      case W3MLogLevel.error:
        return Level.error;
      case W3MLogLevel.wtf:
        return Level.fatal;
      default:
        return Level.off;
    }
  }
}

class W3MLoggerUtil {
  static Logger logger = Logger(
    level: Level.off,
    printer: PrettyPrinter(),
  );

  static void setLogLevel(W3MLogLevel level) {
    logger = Logger(
      level: level.toLevel(),
      printer: PrettyPrinter(
        methodCount: 10,
      ),
    );
  }
}
