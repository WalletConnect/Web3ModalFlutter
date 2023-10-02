import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/grid_item_modal.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';

enum ExcludedWalletState {
  all,
  list,
}

abstract class IExplorerService {
  // implements GridListProvider<WalletData>
  /// The root URI of the explorer API.
  String get explorerUriRoot;

  /// The project ID used when querying the explorer API.
  String get projectId;

  ValueNotifier<List<GridItem<W3MWalletInfo>>> itemList = ValueNotifier([]);

  ValueNotifier<bool> initialized = ValueNotifier(false);

  /// The recommended wallets that will be prioritized in the modal.
  /// Even if the [excludedWalletIds] list contains a wallet, it will still be
  /// displayed if it is in this list.
  Set<String>? recommendedWalletIds;

  /// How the list of excluded wallets will be handled.
  abstract ExcludedWalletState excludedWalletState;

  /// The wallets that will be excluded from the modal.
  Set<String>? excludedWalletIds;

  Future<void> init();

  void filterList({String? query});

  void updateSort();

  String getWalletImageUrl({
    required String imageId,
  });

  String getAssetImageUrl({
    required String imageId,
  });

  Redirect? getRedirect({
    required String name,
  });

  Future<List<Listing>> fetchListings({
    required String endpoint,
    required String referer,
    ListingParams? params,
  });
}
