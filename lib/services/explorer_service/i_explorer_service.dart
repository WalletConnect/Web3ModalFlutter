import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

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

  bool get includeCoinbaseWallet;

  /// If excludedWalletIds is set wallets from this list are going to be excluded
  Set<String>? excludedWalletIds;

  /// Init service
  Future<void> init();

  /// paginate subsequent wallets
  Future<void> paginate();

  bool get canPaginate;

  /// search for a wallet
  void search({String? query});

  ValueNotifier<bool> isSearching = ValueNotifier(false);

  String get searchValue;

  /// update the recently used position to the top list
  Future<void> storeConnectedWallet(W3MWalletInfo? walletInfo);

  /// Get connected wallet data from local storage
  W3MWalletInfo? getConnectedWallet();

  /// Removes connected wallet data from local storage
  Future<void> deleteConnectedWallet();

  /// Gets the WalletRedirect object from a wallet info data
  WalletRedirect? getWalletRedirect(W3MWalletInfo? walletInfo);

  /// Given an imageId it return the wallet app icon from our services
  String getWalletImageUrl(String imageId);

  /// Given an imageId it return the chain icon from our services
  String getAssetImageUrl(String imageId);
}
