import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/utils/core/i_core_utils.dart';

class CoreUtils extends ICoreUtils {
  static const restrictedTimezone = [
    'ASIA/SHANGHAI',
    'ASIA/URUMQI',
    'ASIA/CHONGQING',
    'ASIA/HARBIN',
    'ASIA/KASHGAR',
    'ASIA/MACAU',
    'ASIA/HONG_KONG',
    'ASIA/MACAO',
    'ASIA/BEIJING',
    'ASIA/HARBIN',
  ];

  @override
  bool isValidProjectID(String projectId) {
    return RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(projectId);
  }

  @override
  bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  @override
  Future<bool> isRestrictedRegion() async {
    try {
      String tz = await FlutterTimezone.getLocalTimezone();
      tz = tz.toUpperCase();
      return restrictedTimezone.contains(tz);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> getApiUrl() async {
    final restricted = await isRestrictedRegion();
    if (restricted) {
      return 'https://api.web3modal.org';
    }
    return 'https://api.web3modal.com';
  }

  @override
  Future<String> getBlockchainApiUrl() async {
    final restricted = await isRestrictedRegion();
    if (restricted) {
      return 'https://rpc.walletconnect.org';
    }
    return 'https://rpc.walletconnect.com';
  }

  @override
  Future<String> getAnalyticsUrl() async {
    final restricted = await isRestrictedRegion();
    if (restricted) {
      return 'https://pulse.walletconnect.org';
    }
    return 'https://pulse.walletconnect.com';
  }

  @override
  bool isHttpUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  String createPlainUrl(String url) {
    if (url.isEmpty) return url;

    String plainUrl = url;
    if (!plainUrl.endsWith('/')) {
      plainUrl = '$url/';
    }
    return plainUrl;
  }

  @override
  String createSafeUrl(String url) {
    if (url.isEmpty) return url;

    String safeUrl = url;
    if (!safeUrl.contains('://')) {
      safeUrl = url.replaceAll('/', '').replaceAll(':', '');
      safeUrl = '$safeUrl://';
    } else {
      final parts = safeUrl.split('://');
      if (parts.last.isNotEmpty && parts.last != 'wc') {
        if (!safeUrl.endsWith('/')) {
          return '$safeUrl/';
        }
        return safeUrl;
      } else {
        safeUrl = url.replaceFirst('://wc', '://');
      }
    }
    return safeUrl;
  }

  @override
  Uri? formatCustomSchemeUri(String? appUrl, String? wcUri) {
    if (appUrl == null || appUrl.isEmpty) return null;

    if (isHttpUrl(appUrl)) {
      return formatWebUrl(appUrl, wcUri);
    }

    final safeAppUrl = createSafeUrl(appUrl);

    if (wcUri == null) {
      return Uri.parse(safeAppUrl);
    }

    final encodedWcUrl = Uri.encodeComponent(wcUri);

    return Uri.parse('${safeAppUrl}wc?uri=$encodedWcUrl');
  }

  @override
  Uri? formatWebUrl(String? appUrl, String? wcUri) {
    if (appUrl == null || appUrl.isEmpty) return null;

    if (!isHttpUrl(appUrl)) {
      return formatCustomSchemeUri(appUrl, wcUri);
    }
    String plainAppUrl = createPlainUrl(appUrl);

    if (wcUri == null) {
      return Uri.parse(plainAppUrl);
    }

    final encodedWcUrl = Uri.encodeComponent(wcUri);

    return Uri.parse('${plainAppUrl}wc?uri=$encodedWcUrl');
  }

  @override
  String formatChainBalance(double? chainBalance, {int precision = 3}) {
    if (chainBalance == null) {
      return '_.'.padRight(precision + 1, '_');
    }
    if (chainBalance == 0.0) {
      return '0.'.padRight(precision + 2, '0');
    }
    return chainBalance.toStringAsPrecision(precision)
      ..replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
  }

  @override
  String getUserAgent() {
    String userAgent = '${StringConstants.X_SDK_TYPE}'
        '-flutter-'
        '${StringConstants.X_SDK_VERSION}/'
        '${StringConstants.X_CORE_SDK_VERSION}/'
        '${WalletConnectUtils.getOS()}';
    return userAgent;
  }

  @override
  Map<String, String> getAPIHeaders(String projectId, [String? referer]) {
    return {
      'x-project-id': projectId,
      'x-sdk-type': StringConstants.X_SDK_TYPE,
      'x-sdk-version': 'flutter-${StringConstants.X_SDK_VERSION}',
      'user-agent': getUserAgent(),
      if (referer != null) 'referer': referer,
    };
  }
}
