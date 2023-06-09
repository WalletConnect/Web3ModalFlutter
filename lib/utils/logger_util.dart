import 'package:logger/logger.dart';

class LoggerUtil {
  static final Logger logger = Logger(
    level: Level.info,
    printer: PrettyPrinter(),
  );
}
