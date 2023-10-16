import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/pages/connect_wallet_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_grid.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/explorer_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/all_wallets_header.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';

class WalletsListLongPage extends StatefulWidget {
  const WalletsListLongPage()
      : super(key: Web3ModalKeyConstants.walletListLongPageKey);

  @override
  State<WalletsListLongPage> createState() => _WalletsListLongPageState();
}

class _WalletsListLongPageState extends State<WalletsListLongPage> {
  bool _paginating = false;
  final _controller = ScrollController();

  bool _processScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      setState(() => _paginating = false);
    } else {
      if (notification is UserScrollNotification) {
        return true;
      }
      final extent = _controller.position.maxScrollExtent * 0.9;
      final outOfRange = _controller.position.outOfRange;
      if (_controller.offset >= extent && !outOfRange) {
        if (!_paginating) {
          explorerService.instance!.paginate();
          setState(() => _paginating = true);
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    return Web3ModalNavbar(
      title: 'All Wallets',
      onBack: () {
        FocusManager.instance.primaryFocus?.unfocus();
        explorerService.instance!.search(query: null);
        widgetStack.instance.pop();
      },
      safeAreaBottom: false,
      safeAreaLeft: true,
      safeAreaRight: true,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: ResponsiveData.maxHeightOf(context),
        ),
        child: Column(
          children: [
            const AllWalletsHeader(),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _processScrollNotification,
                child: SingleChildScrollView(
                  controller: _controller,
                  padding: EdgeInsets.only(
                    bottom: ResponsiveData.paddingBottomOf(context),
                  ),
                  child: ExplorerServiceItemsListener(
                    listen: !_paginating,
                    builder: (context, initialised, items) {
                      if (!initialised) {
                        // TODO replace with LoadingItems
                        return const ContentLoading();
                      }
                      return WalletsGrid(
                        isPaginating: _paginating,
                        onTapWallet: (data) async {
                          await service.selectWallet(walletInfo: data);
                          widgetStack.instance.add(const ConnectWalletPage());
                        },
                        itemList: items,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
