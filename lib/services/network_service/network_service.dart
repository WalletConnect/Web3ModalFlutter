import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/network_service/i_network_service.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class NetworkService implements INetworkService {
  @override
  ValueNotifier<bool> initialized = ValueNotifier<bool>(false);

  List<GridItem<W3MChainInfo>> itemListComplete = [];

  @override
  ValueNotifier<List<GridItem<W3MChainInfo>>> itemList =
      ValueNotifier<List<GridItem<W3MChainInfo>>>([]);

  String _getImageUrl(W3MChainInfo chainInfo) {
    if (chainInfo.chainIcon != null && chainInfo.chainIcon!.contains('http')) {
      return chainInfo.chainIcon!;
    }
    final chainImageId = AssetUtil.getChainIconId(chainInfo.chainId);
    return explorerService.instance!.getAssetImageUrl(chainImageId);
  }

  @override
  Future<void> init() async {
    if (initialized.value) {
      return;
    }

    for (var chain in W3MChainPresets.chains.values) {
      final imageUrl = _getImageUrl(chain);
      itemListComplete.add(
        GridItem<W3MChainInfo>(
          image: imageUrl,
          id: chain.chainId,
          title: Util.shorten(chain.chainName),
          data: chain,
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
