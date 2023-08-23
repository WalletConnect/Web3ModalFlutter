import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/network_service.dart/i_network_service.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class NetworkService implements INetworkService {
  @override
  ValueNotifier<bool> initialized = ValueNotifier<bool>(false);

  List<GridListItemModel<W3MChainInfo>> itemListComplete = [];
  @override
  ValueNotifier<List<GridListItemModel<W3MChainInfo>>> itemList =
      ValueNotifier<List<GridListItemModel<W3MChainInfo>>>([]);

  @override
  Future<void> init() async {
    if (initialized.value) {
      return;
    }

    for (var value in ChainData.chainPresets.values) {
      itemListComplete.add(
        GridListItemModel<W3MChainInfo>(
          image: explorerService.instance!.getAssetImageUrl(
            imageId: AssetUtil.getChainIconAssetId(
              value.chainId,
            ),
          ),
          id: value.chainId,
          title: Util.shorten(
            value.chainName,
          ),
          data: value,
        ),
      );
    }

    itemList.value = itemListComplete;

    initialized.value = true;
  }

  @override
  void filterList({String? query}) {
    if (query == null || query.isEmpty) {
      itemList.value = itemListComplete;
      return;
    }

    itemList.value = itemListComplete
        .where(
          (element) => element.title.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }
}
