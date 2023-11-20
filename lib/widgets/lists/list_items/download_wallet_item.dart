import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class DownloadWalletItem extends StatelessWidget {
  const DownloadWalletItem({
    super.key,
    required this.walletInfo,
    this.webOnly = false,
  });
  final W3MWalletInfo walletInfo;
  final bool webOnly;

  String get _storeUrl {
    if (webOnly) {
      return walletInfo.listing.homepage;
    }
    if (Platform.isIOS) {
      return walletInfo.listing.appStore ?? '';
    }
    if (Platform.isAndroid) {
      return walletInfo.listing.playStore ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    if (_storeUrl.isEmpty) {
      return SizedBox.shrink();
    }
    return WalletListItem(
      imageWidget: const SizedBox.shrink(),
      title: 'Don\'t have ${walletInfo.listing.name}?',
      trailing: SimpleIconButton(
        onTap: () => _downloadApp(context),
        title: 'Get',
        rightIcon: 'assets/icons/chevron_right.svg',
        backgroundColor: Colors.transparent,
        foregroundColor: themeColors.accent100,
        size: BaseButtonSize.small,
        fontSize: 14.0,
        iconSize: 12.0,
      ),
    );
  }

  void _downloadApp(BuildContext context) {
    try {
      launchUrlString(
        _storeUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      Web3ModalProvider.of(context).service.connectSelectedWallet();
    }
  }
}
