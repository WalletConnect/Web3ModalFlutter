import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';

class DownloadWalletItem extends StatelessWidget {
  const DownloadWalletItem({
    super.key,
    required this.walletInfo,
  });
  final W3MWalletInfo walletInfo;

  String get _storeIcon {
    if (Platform.isIOS) {
      return 'assets/png/app_store.png';
    }
    if (Platform.isAndroid) {
      return 'assets/png/google_play.png';
    }
    return '';
  }

  String get _storeUrl {
    if (Platform.isIOS) {
      return walletInfo.listing.app.ios ?? '';
    }
    if (Platform.isAndroid) {
      return walletInfo.listing.app.android ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return WalletListItem(
      imageWidget: Image.asset(
        _storeIcon,
        package: 'web3modal_flutter',
      ),
      title: 'Get the app',
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SvgPicture.asset(
          'assets/icons/chevron_right.svg',
          package: 'web3modal_flutter',
          colorFilter: ColorFilter.mode(
            themeData.colors.foreground200,
            BlendMode.srcIn,
          ),
          width: 18.0,
          height: 18.0,
        ),
      ),
      onTap: () {
        try {
          launchUrlString(
            _storeUrl,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          Web3ModalProvider.of(context).service.connectWallet(
                walletInfo: walletInfo,
              );
        }
      },
    );
  }
}
