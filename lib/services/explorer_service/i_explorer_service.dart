import 'package:flutter/material.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';

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

  String get recentWalletId;

  Future<void> init();

  Future<void> paginate();

  void search({String? query});

  void updateRecentPosition(String recentId);

  String getWalletImageUrl(String imageId);

  String getAssetImageUrl(String imageId);

  String? getRedirect({required String name});
}
