import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';

import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';

class NetworkServiceItemsListener extends StatelessWidget {
  const NetworkServiceItemsListener({
    super.key,
    required this.builder,
  });
  final Function(BuildContext context, bool initialised,
      List<GridListItemModel<W3MChainInfo>> items) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: networkService.instance.initialized,
      builder: (context, bool initialised, _) {
        if (!initialised) {
          return builder(context, initialised, []);
        }
        return ValueListenableBuilder(
          valueListenable: networkService.instance.itemList,
          builder: (context, List<GridListItemModel<W3MChainInfo>> items, _) {
            return builder(context, initialised, items);
          },
        );
      },
    );
  }
}
