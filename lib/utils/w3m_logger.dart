import 'package:logger/logger.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class W3MLoggerUtil {
  static Logger logger = Logger(
    level: Level.off,
    printer: PrettyPrinter(),
  );

  static void setLogLevel(LogLevel level) {
    logger = Logger(
      level: level.toLevel(),
      printer: PrettyPrinter(
        methodCount: 10,
      ),
    );
  }
}
