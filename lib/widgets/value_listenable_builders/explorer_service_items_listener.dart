import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';

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
            if (widget.listen) {
              _items = items.toGridItems();
            }
            return widget.builder(context, initialised, _items);
          },
        );
      },
    );
  }
}

extension on List<W3MWalletInfo> {
  List<GridItem<W3MWalletInfo>> toGridItems() {
    List<GridItem<W3MWalletInfo>> gridItems = [];
    for (W3MWalletInfo item in this) {
      gridItems.add(
        GridItem<W3MWalletInfo>(
          title: item.listing.name,
          id: item.listing.id,
          image: explorerService.instance!.getWalletImageUrl(
            item.listing.imageId,
          ),
          data: item,
        ),
      );
    }
    return gridItems;
  }
}
