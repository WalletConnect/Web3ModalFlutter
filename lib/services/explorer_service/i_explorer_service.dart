import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/grid_item_modal.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';

abstract class IExplorerService {
  /// The project ID used when querying the explorer API.
  String get projectId;

  ValueNotifier<List<GridItem<W3MWalletInfo>>> itemList = ValueNotifier([]);

  ValueNotifier<bool> initialized = ValueNotifier(false);

  /// The recommended wallets that will be prioritized in the modal.
  /// Even if the [excludedWalletIds] list contains a wallet, it will still be
  /// displayed if it is in this list.
  Set<String>? recommendedWalletIds;

  Set<String>? includedWalletIds;

  /// The wallets that will be excluded from the modal.
  Set<String>? excludedWalletIds;

  Future<void> init();

  void filterList({String? query});

  // void updateSort();
  void updateRecentPosition(String recentId);

  String getWalletImageUrl(String imageId);

  String getAssetImageUrl(String imageId);

  Redirect? getRedirect({required String name});
}
