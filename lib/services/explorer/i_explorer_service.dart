import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/listings.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_provider.dart';

enum ExcludedWalletState {
  all,
  list,
}

abstract class IExplorerService implements GridListProvider<WalletData> {
  /// The root URI of the explorer API.
  String get explorerUriRoot;

  /// The project ID used when querying the explorer API.
  String get projectId;

  /// The recommended wallets that will be prioritized in the modal.
  /// Even if the [excludedWalletIds] list contains a wallet, it will still be
  /// displayed if it is in this list.
  Set<String>? recommendedWalletIds;

  /// How the list of excluded wallets will be handled.
  abstract ExcludedWalletState excludedWalletState;

  /// The wallets that will be excluded from the modal.
  Set<String>? excludedWalletIds;

  Future<void> init({
    required String referer,
    ListingParams? params,
  });

  String getWalletImageUrl({
    required String imageId,
  });

  String getAssetImageUrl({
    required String imageId,
  });

  Redirect? getRedirect({
    required String name,
  });
}
