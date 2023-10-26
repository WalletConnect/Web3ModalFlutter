import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';

abstract class IUrlUtils {
  const IUrlUtils();

  Future<bool> isInstalled(String? uri);

  Future<bool> launchUrl(Uri url, {LaunchMode? mode});

  Future<void> openRedirect(
    WalletRedirect redirect, {
    String? wcURI,
    PlatformType? pType,
  });
}
