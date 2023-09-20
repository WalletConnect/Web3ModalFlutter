import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';

abstract class IW3MService extends IWalletConnectModalService
    with ChangeNotifier {
  /// The currently selected chain.
  W3MChainInfo? get selectedChain;

  /// Returns the url of the token of the currently selected chain.
  /// Pass this into a [Image.network] and it will load the token image.
  String? get tokenImageUrl;

  /// The url to the account's avatar image.
  /// Pass this into a [Image.network] and it will load the avatar image.
  String? get avatarUrl;

  /// Returns the balance of the currently connected wallet on the selected chain.
  double? get chainBalance;

  /// Sets the selected chain.
  /// If the wallet is already connected, it will request that the chain be changed, and will update the session
  /// with the new chain.
  /// If the [chain] is null, this will disconnect the wallet.
  Future<void> setSelectedChain(
    W3MChainInfo? chain, {
    bool switchChain = false,
  });

  /// Variable that can be used to check if the modal is visible on screen.
  @override
  bool get isOpen;

  /// Opens the modal with the provided [startState].
  /// If none is provided, the default state will be used based on platform.
  @override
  Future<void> open({required BuildContext context, Widget? startWidget});

  /// Closes the modal.
  @override
  void close();

  WalletData? get selectedWallet;
  void selectWallet({required WalletData? walletData});

  bool get hasBlockExplorer;

  void launchBlockExplorer();
}
