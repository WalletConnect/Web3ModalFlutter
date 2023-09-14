import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_grid.dart';
import 'package:web3modal_flutter/widgets/w3m_all_wallets_header.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';

class WalletsListLongPage extends StatelessWidget {
  const WalletsListLongPage()
      : super(key: Web3ModalKeyConstants.walletListLongPageKey);

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;

    return Web3ModalNavbar(
      title: 'All wallets',
      onBack: () {
        explorerService.instance!.filterList(query: null);
        widgetStack.instance.pop();
      },
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: explorerService.instance!.itemList,
            builder:
                (context, List<GridListItemModel<WalletData>> itemList, _) {
              return WalletsGrid(
                viewPortRows: 5,
                onTapWallet: (data) {
                  service.connectWallet(walletData: data);
                },
                itemList: itemList,
              );
            },
          ),
          const AllWalletsHeader(),
        ],
      ),
    );
  }
}
