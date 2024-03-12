import 'package:web3modal_flutter/services/analytics_service/i_analytics_service.dart';

class AnalyticsServiceSingleton {
  late IAnalyticsService instance;
}

final analyticsService = AnalyticsServiceSingleton();
