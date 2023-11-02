import 'package:flutter/material.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';

abstract class IExplorerService {
  /// The project ID used when querying the explorer API.
  String get projectId;

  ValueNotifier<bool> initialized = ValueNotifier(false);

  ValueNotifier<int> totalListings = ValueNotifier(0);

  ValueNotifier<List<W3MWalletInfo>> listings = ValueNotifier([]);

  /// If featuredWalletIds is set wallets from this list are going to be prioritized in the results
  Set<String>? featuredWalletIds;

  /// If includedWalletIds is set only wallets from this list are going to be shown
  Set<String>? includedWalletIds;

  /// If excludedWalletIds is set wallets from this list are going to be excluded
  Set<String>? excludedWalletIds;

  /// Id of the recently used wallet app
  String get recentWalletId;

  /// Init service
  Future<void> init();

  /// fetch initial page of wallets including the installed ones
  Future<void> fetchInitialWallets();

  /// paginate subsequent wallets
  Future<void> paginate();

  /// search for a wallet
  void search({String? query});

  /// update the recently used position to the top list
  Future<void> updateRecentPosition(String? recentId);

  String getWalletImageUrl(String imageId);

  String getAssetImageUrl(String imageId);

  WalletRedirect? getWalletRedirectByName(Listing listing);
}
