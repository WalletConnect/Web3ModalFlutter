import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    debugPrint('[url_utils] _launchUrl $url');
    return await launchUrl(
      url,
      mode: mode ?? LaunchMode.platformDefault,
    );
  } on PlatformException catch (e, s) {
    W3MLoggerUtil.logger.e(
      'Error launching URL $url',
      error: e,
      stackTrace: s,
    );
    throw LaunchUrlException('App not installed');
  } catch (e, s) {
    W3MLoggerUtil.logger.e(
      'Error launching URL $url',
      error: e,
      stackTrace: s,
    );
    throw LaunchUrlException('Error launching app');
  }
}

Future<bool> _androidAppCheck(String uri) async {
  return await AppCheck.isAppEnabled(uri);
}

class UrlUtils extends IUrlUtils {
  UrlUtils({
    this.androidAppCheck = _androidAppCheck,
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
        W3MLoggerUtil.logger.i('[$runtimeType] not installed/detected $uri');
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
  Future<bool> openRedirect(
    WalletRedirect redirect, {
    String? wcURI,
    PlatformType? pType,
  }) async {
    Uri? uriToOpen;
    try {
      final isMobile = (redirect.mobileOnly || pType == PlatformType.mobile);
      if (isMobile && redirect.mobile != null) {
        final uri = wcURI ?? redirect.mobileUri?.toString();
        uriToOpen = coreUtils.instance.formatCustomSchemeUri(
          redirect.mobile,
          uri!,
        );
      }
      //
      final isWeb = (redirect.webOnly || pType == PlatformType.web);
      if (isWeb && redirect.web != null) {
        final uri = wcURI ?? redirect.webUri?.toString();
        uriToOpen = coreUtils.instance.formatWebUrl(
          redirect.web,
          uri!,
        );
      }
      //
      final isDesktop = (redirect.desktopOnly || pType == PlatformType.desktop);
      if (isDesktop && redirect.desktop != null) {
        final uri = wcURI ?? redirect.desktopUri?.toString();
        uriToOpen = coreUtils.instance.formatCustomSchemeUri(
          redirect.desktop,
          uri!,
        );
      }
    } catch (e, s) {
      W3MLoggerUtil.logger.e(
        'Error opening redirect',
        error: e,
        stackTrace: s,
      );
      return false;
    }
    return await launchUrlFunc(
      uriToOpen!,
      mode: LaunchMode.externalApplication,
    );
  }
}
