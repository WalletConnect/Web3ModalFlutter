import 'package:flutter/foundation.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

// @Deprecated('W3MLoggerUtil is going to be deprecated soon. Don\'t use it')
class W3MLoggerUtil {
  static Logger logger = Logger(
    level: Level.off,
    printer: PrettyPrinter(),
  );

  static void setLogLevel(LogLevel level, {bool debugMode = false}) {
    if (kDebugMode && debugMode && level == LogLevel.error) {
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
