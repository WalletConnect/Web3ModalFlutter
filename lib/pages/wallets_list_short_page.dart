import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/pages/qr_code_page.dart';
import 'package:web3modal_flutter/pages/wallet_list_long_page.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/all_wallets_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_connect_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_list.dart';
import 'package:web3modal_flutter/widgets/w3m_navbar.dart';

import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';

class WalletListShortPage extends StatelessWidget {
  const WalletListShortPage()
      : super(key: Web3ModalKeyConstants.walletListShortPageKey);

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final themeData = Web3ModalTheme.getDataOf(context);

    return Web3ModalNavbar(
      title: 'Connect wallet',
      child: ValueListenableBuilder(
        valueListenable: explorerService.instance!.initialized,
        builder: (context, bool initialized, _) {
          if (initialized) {
            return ValueListenableBuilder(
              valueListenable: explorerService.instance!.itemList,
              builder: (context, List<GridListItemModel<WalletData>> itemList,
                  child) {
                return WalletsList(
                  onTapWallet: (data) {
                    service.connectWallet(walletData: data);
                  },
                  itemList: itemList.getRange(0, kItemsCount - 2).toList(),
                  firstItem: WalletConnectItem(
                    onTap: () {
                      widgetStack.instance.add(const QRCodePage());
                    },
                  ),
                  lastItem: AllWalletsItem(
                    trailing: WalletItemChip(value: '${itemList.length}+'),
                    onTap: () {
                      widgetStack.instance.add(const WalletListLongPage());
                    },
                  ),
                );
              },
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(8.0),
              height: (kListItemHeight * kItemsCount) + (8 * kItemsCount) + 12,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: themeData.colors.blue100,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
