import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';

abstract class IAnalyticsService {
  String get projectId;
  bool? get enableAnalytics;
  Stream<dynamic> get events;
  Future<void> init();
  void sendEvent(AnalyticsEvent analyticsEvent);
  Future<bool> fetchAnalyticsConfig();
}
