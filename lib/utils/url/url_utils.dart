import 'package:appcheck/appcheck.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/utils/url/i_url_utils.dart';
import 'package:web3modal_flutter/utils/url/launch_url_exception.dart';

import 'package:web3modal_flutter/utils/w3m_logger.dart';

Future<bool> _launchUrl(Uri url, {LaunchMode? mode}) async {
  try {
    return await launchUrl(
      url,
      mode: mode ?? LaunchMode.platformDefault,
    );
  } catch (e) {
    W3MLoggerUtil.logger.e(
      'Error launching URL: ${url.toString()}',
    );
    W3MLoggerUtil.logger.e(e);
    throw LaunchUrlException(
      'Error launching URL: ${url.toString()}',
    );
  }
}

Future<bool> _androidLaunch(String uri) async {
  return await AppCheck.isAppEnabled(uri);
}

class UrlUtils extends IUrlUtils {
  UrlUtils({
    this.androidAppCheck = _androidLaunch,
    this.launchUrlFunc = _launchUrl,
    this.canLaunchUrlFunc = canLaunchUrl,
  });

  final Future<bool> Function(String uri) androidAppCheck;
  final Future<bool> Function(Uri url, {LaunchMode? mode}) launchUrlFunc;
  final Future<bool> Function(Uri url) canLaunchUrlFunc;

  @override
  Future<bool> isInstalled(String? uri) async {
    if (uri == null || uri.isEmpty) {
      return false;
    }

    // If the wallet is just a generic wc:// then it is not installed
    if (uri.contains('wc://')) {
      return false;
    }

    if (platformUtils.instance.canDetectInstalledApps()) {
      final p = platformUtils.instance.getPlatformExact();
      try {
        if (p == PlatformExact.android) {
          return await androidAppCheck(uri);
        } else if (p == PlatformExact.iOS) {
          return await canLaunchUrlFunc(Uri.parse(uri));
        }
      } catch (e) {
        W3MLoggerUtil.logger.i('[$runtimeType] isInstalled $uri $e');
      }
    }

    return false;
  }

  @override
  Future<bool> launchUrl(Uri url, {LaunchMode? mode}) async {
    return launchUrlFunc(
      url,
      mode: mode,
    );
  }

  @override
  Future<void> openRedirect(
    WalletRedirect redirect, {
    String? wcURI,
    PlatformType? pType,
  }) async {
    try {
      Uri? uriToOpen;
      if ((redirect.mobileOnly || pType == PlatformType.mobile) &&
          redirect.mobile != null) {
        uriToOpen = wcURI != null
            ? coreUtils.instance.formatCustomSchemeUri(
                redirect.mobile,
                wcURI,
              )
            : redirect.mobileUri;
      }
      if ((redirect.webOnly || pType == PlatformType.web) &&
          redirect.web != null) {
        uriToOpen = wcURI != null
            ? coreUtils.instance.formatWebUrl(
                redirect.web,
                wcURI,
              )
            : redirect.webUri;
      }
      if ((redirect.desktopOnly || pType == PlatformType.desktop) &&
          redirect.desktop != null) {
        uriToOpen = wcURI != null
            ? coreUtils.instance.formatCustomSchemeUri(
                redirect.desktop,
                wcURI,
              )
            : redirect.desktopUri;
      }
      try {
        await launchUrlFunc(uriToOpen!, mode: LaunchMode.externalApplication);
      } catch (_) {
        throw LaunchUrlException('App not installed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
