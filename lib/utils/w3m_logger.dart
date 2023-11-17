import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class W3MLoggerUtil {
  static Logger logger = Logger(
    level: Level.off,
    printer: PrettyPrinter(),
  );

  static void setLogLevel(LogLevel level) {
    if (kDebugMode && level == LogLevel.verbose) {
      Logger.addLogListener((LogEvent event) => debugPrint('${event.message}'));
    }
    logger = Logger(
      level: level.toLevel(),
      printer: PrettyPrinter(
        methodCount: 10,
      ),
    );
  }
}
