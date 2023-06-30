import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/services/utils/core/i_core_utils.dart';
import 'package:web3modal_flutter/utils/constants.dart';
import 'package:web3modal_flutter/utils/logger_util.dart';

class CoreUtils extends ICoreUtils {
  @override
  bool isHttpUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Uri? formatNativeUrl(String? appUrl, String wcUri) {
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

  @override
  Uri? formatUniversalUrl(String? appUrl, String wcUri) {
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

  @override
  String getUserAgent() {
    final String os = WalletConnectUtils.getOS();
    return 'w3m-flutter-${Web3ModalConstants.WEB3MODAL_VERSION}/flutter-core-${WalletConnectConstants.SDK_VERSION}/$os';
  }
}
