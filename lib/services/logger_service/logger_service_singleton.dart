import 'package:web3modal_flutter/services/logger_service/i_logger_service.dart';

class LoggerServiceSingleton {
  late ILoggerService instance;
}

final loggerService = LoggerServiceSingleton();
