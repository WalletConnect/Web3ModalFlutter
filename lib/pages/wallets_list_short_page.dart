import 'dart:math';

import 'package:flutter/material.dart';

import 'package:web3modal_flutter/pages/about_wallets.dart';
import 'package:web3modal_flutter/pages/connect_wallet_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/pages/wallets_list_long_page.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/all_wallets_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_list.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/explorer_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class WalletsListShortPage extends StatefulWidget {
  const WalletsListShortPage()
      : super(key: Web3ModalKeyConstants.walletListShortPageKey);

  @override
  State<WalletsListShortPage> createState() => _WalletsListShortPageState();
}

class _WalletsListShortPageState extends State<WalletsListShortPage> {
  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final isPortrait = ResponsiveData.isPortrait(context);
    double maxHeight = isPortrait
        ? (kListItemHeight * 6)
        : ResponsiveData.maxHeightOf(context);
    return Web3ModalNavbar(
      title: 'Connect wallet',
      leftAction: NavbarActionButton(
        asset: 'assets/icons/help.svg',
        action: () {
          widgetStack.instance.push(const AboutWallets());
        },
      ),
      safeAreaLeft: true,
      safeAreaRight: true,
      body: ExplorerServiceItemsListener(
        builder: (context, initialised, items, _) {
          if (!initialised || items.isEmpty) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: const WalletsList(
                isLoading: true,
                itemList: [],
              ),
            );
          }
          final itemsCount = min(kShortWalletListCount, items.length);
          final itemsToShow = items.getRange(0, itemsCount);
          if (itemsCount < kShortWalletListCount && isPortrait) {
            maxHeight = kListItemHeight * (itemsCount + 1);
          }
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: WalletsList(
              onTapWallet: (data) {
                service.selectWallet(data);
                widgetStack.instance.push(const ConnectWalletPage());
              },
              itemList: itemsToShow.toList(),
              lastItem: (itemsCount < kShortWalletListCount)
                  ? null
                  : AllWalletsItem(
                      trailing: ValueListenableBuilder<int>(
                        valueListenable:
                            explorerService.instance!.totalListings,
                        builder: (context, value, _) {
                          return WalletItemChip(value: value.lazyCount);
                        },
                      ),
                      onTap: () {
                        widgetStack.instance.push(const WalletsListLongPage());
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}

extension on int {
  String get lazyCount {
    if (this <= 10) return toString();
    return '${toString().substring(0, toString().length - 1)}0+';
  }
}
