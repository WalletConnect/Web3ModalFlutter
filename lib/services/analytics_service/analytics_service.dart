import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:web3modal_flutter/services/analytics_service/i_analytics_service.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class AnalyticsService implements IAnalyticsService {
  static final _eventsController = StreamController<dynamic>.broadcast();
  static const _debugApiEndpoint =
      'https://analytics-api-cf-workers-staging.walletconnect-v1-bridge.workers.dev';
  static const _debugProjectId = 'e087b4b0503b860119be49d906717c12';
  bool _isEnabled = false;
  late final String _bundleId;
  late final String _endpoint;

  @override
  final Stream<dynamic> events = _eventsController.stream;

  @override
  final String projectId;

  @override
  final bool? enableAnalytics;

  AnalyticsService({
    required this.projectId,
    this.enableAnalytics,
  });

  @override
  Future<void> init() async {
    try {
      if (enableAnalytics == null) {
        _isEnabled = await fetchAnalyticsConfig();
      } else {
        _isEnabled = enableAnalytics!;
      }
      _bundleId = await WalletConnectUtils.getPackageName();
      _endpoint = kDebugMode
          ? _debugApiEndpoint
          : await coreUtils.instance.getAnalyticsUrl();
      loggerService.instance.p('[$runtimeType] enabled: $_isEnabled');
    } catch (e, s) {
      loggerService.instance.p(
        '[$runtimeType] init error',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<bool> fetchAnalyticsConfig() async {
    try {
      final apiUrl = await coreUtils.instance.getApiUrl();
      final headers = coreUtils.instance.getAPIHeaders(projectId);
      final response = await http.get(
        Uri.parse('$apiUrl/getAnalyticsConfig'),
        headers: headers,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final enabled = json['isAnalyticsEnabled'] as bool?;
      return enabled ?? false;
    } catch (e, s) {
      loggerService.instance.p(
        '[$runtimeType] fetch remote configuration error',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  @override
  void sendEvent(AnalyticsEvent analyticsEvent) async {
    if (!_isEnabled) return;
    try {
      final headers = kDebugMode
          ? coreUtils.instance.getAPIHeaders(_debugProjectId)
          : coreUtils.instance.getAPIHeaders(projectId);

      final body = jsonEncode({
        'eventId': Uuid().v4(),
        'bundleId': _bundleId,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        'props': analyticsEvent.toMap(),
      });

      final response = await http.post(
        Uri.parse('$_endpoint/e'),
        headers: headers,
        body: body,
      );
      final code = response.statusCode;
      if (code == 200 || code == 202) {
        _eventsController.sink.add(analyticsEvent.toMap());
      }
      loggerService.instance.p('[$runtimeType] send event $code: $body');
    } catch (e, s) {
      loggerService.instance.p(
        '[$runtimeType] send event error',
        error: e,
        stackTrace: s,
      );
    }
  }
}
