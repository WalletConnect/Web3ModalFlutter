import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/grid_item_modal.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';

class ExplorerServiceItemsListener extends StatelessWidget {
  const ExplorerServiceItemsListener({
    super.key,
    required this.builder,
  });
  final Function(BuildContext context, bool initialised,
      List<GridItem<W3MWalletInfo>> items) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: explorerService.instance!.initialized,
      builder: (context, initialised, _) {
        if (!initialised) {
          return builder(context, initialised, []);
        }
        return ValueListenableBuilder<List<GridItem<W3MWalletInfo>>>(
          valueListenable: explorerService.instance!.itemList,
          builder: (context, items, _) {
            return builder(context, initialised, items);
          },
        );
      },
    );
  }
}
