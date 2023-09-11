import 'package:flutter/material.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/pages/qr_code_page.dart';
import 'package:web3modal_flutter/pages/wallet_list_long_page.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_wallet_item.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_icon_button.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';

class WalletListShortPage extends StatelessWidget {
  const WalletListShortPage()
      : super(key: Web3ModalKeyConstants.walletListShortPageKey);

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;

    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Connect your wallet',
      ),
      actionWidget: WalletConnectIconButton(
        iconPath: 'assets/icons/qr_code.svg',
        onPressed: () {
          widgetStack.instance.add(
            const QRCodePage(),
          );
        },
      ),
      child: GridList<WalletData>(
        state: GridListState.short,
        provider: explorerService.instance!,
        viewLongList: () {
          widgetStack.instance.add(
            const WalletListLongPage(),
          );
        },
        onSelect: (WalletData data) {
          service.connectWallet(
            walletData: data,
          );
        },
        createListItem: (info, iconSize) {
          debugPrint('list item ${info.title}');
          return GridListWalletItem(
            listItem: info,
            imageSize: iconSize,
          );
        },
      ),
    );
  }
}
