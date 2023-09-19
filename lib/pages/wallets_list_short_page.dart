import 'package:flutter/material.dart';
import 'package:web3modal_flutter/pages/about_wallets.dart';
import 'package:web3modal_flutter/pages/connect_wallet_page.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/pages/qr_code_page.dart';
import 'package:web3modal_flutter/pages/wallets_list_long_page.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/all_wallets_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_connect_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_list.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/explorer_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/w3m_content_loading.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class WalletsListShortPage extends StatelessWidget {
  const WalletsListShortPage()
      : super(key: Web3ModalKeyConstants.walletListShortPageKey);

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;

    return Web3ModalNavbar(
      title: 'Connect wallet',
      leftAction: NavbarActionButton(
        asset: 'assets/icons/help.svg',
        action: () {
          widgetStack.instance.add(const AboutWallets());
        },
      ),
      child: SafeArea(
        child: ExplorerServiceItemsListener(
          builder: (context, initialised, items) {
            if (!initialised) {
              return const ContentLoading();
            }

            final itemsToShow = items.getRange(0, kShortWalletListCount - 2);
            return WalletsList(
              onTapWallet: (data) {
                service.selectWallet(walletData: data);
                widgetStack.instance.add(const ConnectWalletPage());
              },
              itemList: itemsToShow.toList(),
              firstItem: WalletConnectItem(
                onTap: () {
                  widgetStack.instance.add(const QRCodePage());
                },
              ),
              lastItem: AllWalletsItem(
                trailing: WalletItemChip(value: '${items.length}+'),
                onTap: () {
                  widgetStack.instance.add(const WalletsListLongPage());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
