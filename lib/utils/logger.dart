import 'package:logger/logger.dart';

class LoggerUtil {
  static Logger logger = Logger(
    level: Level.nothing,
    printer: PrettyPrinter(),
  );

  static void setLogLevel(Level level) {
    logger = Logger(
      level: level,
      printer: PrettyPrinter(
        methodCount: 10,
      ),
    );
  }
}
