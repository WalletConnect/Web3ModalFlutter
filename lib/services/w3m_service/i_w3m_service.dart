import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/i_web3app.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';

abstract class IW3MService with ChangeNotifier {
  /// Whether or not this object has been initialized.
  bool get isInitialized;

  /// If the [web3App] fails to initialize and throws an exception, this will contain the caught exception.
  /// Otherwise, it will be null.
  dynamic get initError;

  /// The required namespaces that will be used when connecting to the wallet
  Map<String, RequiredNamespace> get requiredNamespaces;

  /// The optional namespaces that will be used when connecting to the wallet
  Map<String, RequiredNamespace> get optionalNamespaces;

  /// The object that manages sessions, authentication, events, and requests for WalletConnect.
  IWeb3App? get web3App;

  /// Variable that can be used to check if the modal is visible on screen.
  bool get isOpen;

  /// Variable that can be used to check if the web3App is connected
  bool get isConnected;

  /// The URI that can be used to connect to this dApp.
  /// This is only available after the [openModal] function is called.
  String? get wcUri;

  /// The current session's data.
  SessionData? get session;

  /// The address of the currently connected account.
  String? get address;

  /// Returns the url of the token of the currently selected chain.
  /// Pass this into a [Image.network] and it will load the token image.
  String? get tokenImageUrl;

  /// The url to the account's avatar image.
  /// Pass this into a [Image.network] and it will load the avatar image.
  String? get avatarUrl;

  /// The currently selected chain.
  W3MChainInfo? get selectedChain;

  /// Returns the balance of the currently connected wallet on the selected chain.
  double? get chainBalance;

  /// The currently selected wallet.
  W3MWalletInfo? get selectedWallet;

  /// Sets the [selectedChain] and gets the [chainBalance].
  /// If the wallet is already connected, it will request the chain to be changed and will update the session with the new chain.
  /// If [chainInfo] is null this will disconnect the wallet.
  Future<void> selectChain(W3MChainInfo? chainInfo, {bool switchChain = false});

  void launchBlockExplorer();

  /// Sets up the explorer and the web3App if they already been initialized.
  Future<void> init();

  /// Opens the modal with the provided [startWidget] (if any).
  /// If none is provided, the default state will be used based on platform.
  Future<void> openModal(BuildContext context, [Widget? startWidget]);

  /// Connects to the relay if not already connected.
  /// If the relay is already connected, this does nothing.
  Future<void> reconnectRelay();

  /// Sets the [selectedWallet] to be connected
  Future<void> selectWallet({required W3MWalletInfo? walletInfo});

  /// Used to expire and delete any inactive pairing
  Future<void> expirePreviousInactivePairings();

  /// This will do nothing if [isConnected] is true.
  Future<void> buildConnectionUri();

  /// Subscribe to listen to pairing expirations
  final Event<EventArgs> onPairingExpire = Event();

  // TODO remove the walletInfo argument as not really needed
  /// Connects the [selectedWallet] previously selected
  Future<void> connectWallet([W3MWalletInfo? walletInfo]);

  /// Opens the native wallet [selectedWallet] after connected
  Future<void> launchConnectedWallet();

  /// Gets the name of the currently connected wallet.
  String getReferer();

  /// Closes the modal.
  void closeModal();

  /// Disconnects the session and pairing, if any.
  /// If there is no session, this does nothing.
  Future<void> disconnect({bool disconnectAllSessions = true});

  @override
  void dispose();
}
