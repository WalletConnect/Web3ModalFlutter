import 'package:flutter/material.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

abstract class IWalletConnectModalService implements ChangeNotifier {
  /// Whether or not this object has been initialized.
  bool get isInitialized;

  /// The project ID used to initialize the [web3App].
  String get projectId;

  /// The object that manages sessions, authentication, events, and requests
  /// for WalletConnect.
  IWeb3App? get web3App;

  /// If the [web3App] fails to initialize and throws an exception, this will contain the caught exception.
  /// Otherwise, it will be null.
  dynamic get initError;

  /// Variable that can be used to check if the modal is visible on screen.
  bool get isOpen;

  /// Variable that can be used to check if the web3App is connected
  bool get isConnected;

  /// The current session's data.
  SessionData? get session;

  /// The address of the currently connected account.
  String? get address;

  /// The URI that can be used to connect to this dApp.
  /// This is only available after the [open] function is called.
  String? get wcUri;

  /// The service used to fetch wallet listings from the explorer API.
  // abstract final IExplorerService explorerService;

  /// Sets up the explorer and the web3App if they already been initialized.
  Future<void> init();

  /// Opens the modal with the provided [startState].
  /// If none is provided, the default state will be used based on platform.
  Future<void> open({
    required BuildContext context,
    Widget? startWidget,
  });

  /// Closes the modal.
  void close();

  /// Connects to the relay if not already connected.
  /// If the relay is already connected, this does nothing.
  Future<void> reconnectRelay();

  /// Disconnects the session and pairing, if any.
  /// If there is no session, this does nothing.
  Future<void> disconnect({
    bool disconnectAllSessions = true,
  });

  Future<void> launchCurrentWallet();

  Future<void> connectWallet({required W3MWalletInfo walletInfo});

  /// The required namespaces that will be used when connecting to the wallet
  Map<String, RequiredNamespace> get requiredNamespaces;

  /// The optional namespaces that will be used when connecting to the wallet
  Map<String, RequiredNamespace> get optionalNamespaces;

  /// Sets the required namespaces that will be used when connecting to the wallet
  /// The default is blank. If you are building a multichain dApp it is recommended
  /// you use the optional namespaces instead so you dApp can function with more
  /// wallets.
  void setRequiredNamespaces({
    required Map<String, RequiredNamespace> requiredNamespaces,
  });

  /// Sets the optional namespaces that will be used when connecting to the wallet
  /// The default is set to the [NamespaceConstants.ethereum] namespace.
  void setOptionalNamespaces({
    required Map<String, RequiredNamespace> optionalNamespaces,
  });

  /// Rebuilds the connection URI.
  /// If the dapp attempts to connect to a wallet, and the connection proposal is consumed,
  /// but not accepted or rejected (no response), and they navigate back to the dapp and try again
  /// then no connection proposal will be sent. This is because the connection proposal is already consumed.
  /// So, every time they tap on a button to connect to a wallet, we need to rebuild the connection URI to
  /// ensure that each time they tap on a wallet, a new connection proposal is sent.
  ///
  /// This will do nothing if [isConnected] is true.
  Future<void> rebuildConnectionUri();

  /// Sets the required namespaces that will be used when connecting to the wallet
  /// The default is set to the [NamespaceConstants.ethereum] namespace.
  // void setRequiredNamespaces(
  //   Map<String, RequiredNamespace> requiredNamespaces,
  // );

  // /// Sets the recommended wallets to display in the modal.
  // void setRecommendedWallets(
  //   Set<String> walletIds,
  // );

  // /// Sets the list of wallets to exclude from the modal.
  // void setExcludedWallets(
  //   ExcludedWalletState state,
  //   Set<String> walletIds,
  // );

  /// Gets the name of the currently connected wallet.
  String getReferer();
}
