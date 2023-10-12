import 'dart:io';

import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/services/utils/url/url_utils_singleton.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';

class ExplorerServiceItemsListener extends StatefulWidget {
  const ExplorerServiceItemsListener({
    super.key,
    required this.builder,
    this.listen = true,
  });
  final Function(
    BuildContext context,
    bool initialised,
    List<GridItem<W3MWalletInfo>> items,
  ) builder;
  final bool listen;

  @override
  State<ExplorerServiceItemsListener> createState() =>
      _ExplorerServiceItemsListenerState();
}

class _ExplorerServiceItemsListenerState
    extends State<ExplorerServiceItemsListener> {
  List<GridItem<W3MWalletInfo>> _items = [];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: explorerService.instance!.initialized,
      builder: (context, initialised, _) {
        if (!initialised) {
          return widget.builder(context, initialised, []);
        }
        return ValueListenableBuilder<List<W3MWalletInfo>>(
          valueListenable: explorerService.instance!.listings,
          builder: (context, items, _) {
            return FutureBuilder<List<GridItem<W3MWalletInfo>>>(
              future: items.toGridItems(),
              builder: (context, snapshot) {
                if (widget.listen) {
                  _items = snapshot.data ?? [];
                }
                return widget.builder(context, initialised, _items);
              },
            );
          },
        );
      },
    );
  }
}

extension on List<W3MWalletInfo> {
  Future<List<GridItem<W3MWalletInfo>>> toGridItems() async {
    final recentWallet = storageService.instance.getString(
      StringConstants.recentWallet,
    );
    List<GridItem<W3MWalletInfo>> gridItems = [];
    for (W3MWalletInfo item in this) {
      String? appScheme = item.listing.mobileLink;
      // If we are on android, and we have an android link, get the package id and use that
      if (Platform.isAndroid && item.listing.playStore != null) {
        appScheme = explorerService.instance!.getAndroidPackageId(
          item.listing.playStore,
        );
      }
      bool installed = await urlUtils.instance.isInstalled(appScheme);
      bool recent = recentWallet == item.listing.id;
      gridItems.add(
        GridItem<W3MWalletInfo>(
          title: item.listing.name,
          id: item.listing.id,
          image: explorerService.instance!.getWalletImageUrl(
            item.listing.imageId,
          ),
          data: item.copyWith(
            installed: installed,
            recent: recent,
          ),
        ),
      );
    }
    return gridItems;
  }
}
