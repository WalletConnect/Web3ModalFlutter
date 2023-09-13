import 'package:flutter/material.dart';

import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';

class ExplorerServiceItemsListener extends StatelessWidget {
  const ExplorerServiceItemsListener({
    super.key,
    required this.builder,
  });
  final Function(BuildContext context, bool initialised,
      List<GridListItemModel<WalletData>> items) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: explorerService.instance!.initialized,
      builder: (context, bool initialised, _) {
        if (!initialised) {
          return builder(context, initialised, []);
        }
        return ValueListenableBuilder(
          valueListenable: explorerService.instance!.itemList,
          builder: (context, List<GridListItemModel<WalletData>> items, _) {
            return builder(context, initialised, items);
          },
        );
      },
    );
  }
}
