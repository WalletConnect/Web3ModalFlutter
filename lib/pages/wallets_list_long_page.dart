import 'dart:math';

import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/pages/connect_wallet_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_grid.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/explorer_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/all_wallets_header.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

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
          _paginate();
        }
      }
    }
    return true;
  }

  Future<void> _paginate() {
    setState(() => _paginating = explorerService.instance!.canPaginate);
    return explorerService.instance!.paginate();
  }

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final totalListings = explorerService.instance!.totalListings.value;
    final rows = (totalListings / 4.0).ceil();
    final maxHeight = (rows * kGridItemHeight) +
        (kPadding16 * 2.0) +
        ResponsiveData.paddingBottomOf(context);
    final isSearchAvailable = totalListings >= 20;
    return Web3ModalNavbar(
      title: 'All wallets',
      onTapTitle: () => _controller.animateTo(
        0,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      ),
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
          maxHeight: !isSearchAvailable
              ? maxHeight
              : ResponsiveData.maxHeightOf(context),
        ),
        child: Column(
          children: [
            isSearchAvailable ? const AllWalletsHeader() : SizedBox.shrink(),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _processScrollNotification,
                child: ExplorerServiceItemsListener(
                  listen: !_paginating,
                  builder: (context, initialised, items, searching) {
                    if (!initialised || searching) {
                      return WalletsGrid(
                        paddingTop: isSearchAvailable ? 0.0 : kPadding16,
                        showLoading: true,
                        loadingCount:
                            items.isNotEmpty ? min(16, items.length) : 16,
                        scrollController: _controller,
                        itemList: [],
                      );
                    }
                    final isPortrait = ResponsiveData.isPortrait(context);
                    return WalletsGrid(
                      paddingTop: isSearchAvailable ? 0.0 : kPadding16,
                      showLoading: _paginating,
                      loadingCount: isPortrait ? 4 : 8,
                      scrollController: _controller,
                      onTapWallet: (data) async {
                        service.selectWallet(data);
                        widgetStack.instance.push(const ConnectWalletPage());
                      },
                      itemList: items,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
