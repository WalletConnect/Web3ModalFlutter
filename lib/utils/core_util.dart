import 'package:web3modal_flutter/utils/logger_util.dart';

class CoreUtil {
  static bool isHttpUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static Uri? formatNativeUrl(String? appUrl, String wcUri) {
    if (appUrl == null || appUrl.isEmpty) return null;

    if (isHttpUrl(appUrl)) {
      return formatUniversalUrl(appUrl, wcUri);
    }

    String safeAppUrl = appUrl;
    if (!safeAppUrl.contains('://')) {
      safeAppUrl = appUrl.replaceAll('/', '').replaceAll(':', '');
      safeAppUrl = '$safeAppUrl://';
    }

    String encodedWcUrl = Uri.encodeComponent(wcUri);
    LoggerUtil.logger.i('Encoded WC URL: $encodedWcUrl');

    return Uri.parse('${safeAppUrl}wc?uri=$encodedWcUrl');
  }

  static Uri? formatUniversalUrl(String? appUrl, String wcUri) {
    if (appUrl == null || appUrl.isEmpty) return null;

    if (!isHttpUrl(appUrl)) {
      return formatNativeUrl(appUrl, wcUri);
    }
    String plainAppUrl = appUrl;
    if (appUrl.endsWith('/')) {
      plainAppUrl = appUrl.substring(0, appUrl.length - 1);
    }

    String encodedWcUrl = Uri.encodeComponent(wcUri);
    LoggerUtil.logger.i('Encoded WC URL: $encodedWcUrl');

    return Uri.parse('$plainAppUrl/wc?uri=$encodedWcUrl');
  }
}
