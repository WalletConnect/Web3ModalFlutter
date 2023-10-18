import 'dart:async';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'package:web3modal_flutter/constants/namespaces.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service_singleton.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/url/launch_url_exception.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils_singleton.dart';
import 'package:web3modal_flutter/services/network_service/network_service_singleton.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/models/w3m_chains_presets.dart';
import 'package:web3modal_flutter/utils/eth_util.dart';
import 'package:web3modal_flutter/widgets/web3modal.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/services/w3m_service/w3m_services_instances.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/utils/url/url_utils_singleton.dart';

class W3MServiceException implements Exception {
  final dynamic message;
  final dynamic stackTrace;
  W3MServiceException(this.message, [this.stackTrace]) : super();
}

class W3MService with ChangeNotifier implements IW3MService {
  static const String selectedChainId = 'selectedChainId';

  var _projectId = '';

  bool _isInitialized = false;
  @override
  bool get isInitialized => _isInitialized;

  W3MChainInfo? _currentSelectedChain;
  @override
  W3MChainInfo? get selectedChain => _currentSelectedChain;

  W3MWalletInfo? _selectedWallet;
  @override
  W3MWalletInfo? get selectedWallet => _selectedWallet;

  Map<String, RequiredNamespace> _requiredNamespaces = {};
  @override
  Map<String, RequiredNamespace> get requiredNamespaces => _requiredNamespaces;

  Map<String, RequiredNamespace> _optionalNamespaces =
      NamespaceConstants.ethereum;
  @override
  Map<String, RequiredNamespace> get optionalNamespaces => _optionalNamespaces;

  ConnectResponse? connectResponse;
  Future<SessionData>? get sessionFuture => connectResponse?.session.future;

  BuildContext? _context;

  @override
  String? get wcUri => connectResponse?.uri.toString();

  IWeb3App? _web3App;
  @override
  IWeb3App? get web3App => _web3App;

  dynamic _initError;
  @override
  dynamic get initError => _initError;

  String? _tokenImageUrl;
  @override
  String? get tokenImageUrl => _tokenImageUrl;

  String? _avatarUrl;
  @override
  String? get avatarUrl => _avatarUrl;

  double? _chainBalance;
  @override
  double? get chainBalance => _chainBalance;

  bool _isOpen = false;
  @override
  bool get isOpen => _isOpen;

  bool _isConnected = false;
  @override
  bool get isConnected => _isConnected;

  SessionData? _currentSession;
  @override
  SessionData? get session => _currentSession;

  String? _address;
  @override
  String? get address => _address;

  @override
  final Event<EventArgs> onPairingExpire = Event();

  bool _connectingWallet = false;

  W3MService({
    IWeb3App? web3App,
    String? projectId,
    PairingMetadata? metadata,
    Map<String, RequiredNamespace>? requiredNamespaces,
    Map<String, RequiredNamespace>? optionalNamespaces,
    Set<String>? featuredWalletIds,
    Set<String>? includedWalletIds,
    Set<String>? excludedWalletIds,
  }) {
    if (web3App == null && projectId == null && metadata == null) {
      throw ArgumentError(
        'Either a projectId and metadata must be provided or an already created web3App.',
      );
    }

    _web3App = web3App ??
        Web3App(
          core: Core(projectId: projectId!),
          metadata: metadata!,
        );
    _projectId = projectId ?? _web3App!.core.projectId;

    if (requiredNamespaces != null) {
      _requiredNamespaces = requiredNamespaces;
    }
    if (optionalNamespaces != null) {
      _optionalNamespaces = optionalNamespaces;
    }

    explorerService.instance = ExplorerService(
      projectId: _projectId,
      referer: _web3App!.metadata.name.replaceAll(' ', ''),
      featuredWalletIds: featuredWalletIds,
      includedWalletIds: includedWalletIds,
      excludedWalletIds: excludedWalletIds,
    );

    blockchainApiUtils.instance = BlockchainApiUtils(
      projectId: _projectId,
    );

    Web3ModalServiceInstances.registerInitFunction(
      'network_service',
      () async {
        await networkService.instance.init();
      },
    );
    Web3ModalServiceInstances.registerInitFunction(
      'storage_service',
      () async {
        await storageService.instance.init();
      },
    );
  }

  ////////* PUBLIC METHODS */////////

  @override
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _initError = null;

    await expirePreviousInactivePairings();

    _registerListeners();

    try {
      await _web3App!.init();
    } catch (e, s) {
      throw W3MServiceException(e, s);
    }

    final currentPairings = _web3App!.pairings.getAll();
    final currentSessions = _web3App!.sessions.getAll();

    if (currentSessions.isNotEmpty) {
      _isConnected = true;
      _currentSession = currentSessions.first;
      _address = NamespaceUtils.getAccount(
        _currentSession!.namespaces.values.first.accounts.first,
      );
      // session should not outlive the pairing
      if (currentPairings.isEmpty) {
        await disconnect();
      }
    }

    try {
      await Web3ModalServiceInstances.init();
    } catch (e, s) {
      throw W3MServiceException(e, s);
    }

    // Set the optional namespaces to everything in our asset util.
    final List<String> chainIds = [];
    for (final String id in W3MChainPresets.chains.keys) {
      chainIds.add('eip155:$id');
    }
    final Map<String, RequiredNamespace> optionalNamespaces = {
      'eip155': RequiredNamespace(
        methods: EthUtil.ethMethods,
        chains: chainIds,
        events: EthUtil.ethEvents,
      ),
    };
    _setOptionalNamespaces(optionalNamespaces);

    // Get the chainId of the chain we are connected to.
    if (_currentSession != null) {
      final chainId = storageService.instance.getString(selectedChainId) ?? '';
      // If we had a chainId stored, use it!
      if (chainId.isNotEmpty && W3MChainPresets.chains.containsKey(chainId)) {
        await selectChain(W3MChainPresets.chains[chainId]!);
      } else {
        // Otherwise, just get the first chainId from the namespaces of the session and use that
        final chainIds = NamespaceUtils.getChainIdsFromNamespaces(
          namespaces: _currentSession!.namespaces,
        );
        if (chainIds.isNotEmpty) {
          final String chainId = chainIds.first.split(':')[1];
          // If we have the chain in our presets, set it as the selected chain
          if (W3MChainPresets.chains.containsKey(chainId)) {
            await selectChain(W3MChainPresets.chains[chainId]!);
          }
        }
      }
    }

    W3MLoggerUtil.logger.t('[$runtimeType] initialized');
    _notify();
  }

  @override
  Future<void> selectChain(
    W3MChainInfo? chainInfo, {
    bool switchChain = false,
  }) async {
    _checkInitialized();

    if (chainInfo?.chainId == _currentSelectedChain?.chainId) {
      return;
    }

    _chainBalance = null;
    _tokenImageUrl = null;

    // If the chain is null, disconnect and stop.
    if (chainInfo == null) {
      _currentSelectedChain = null;
      await storageService.instance.setString(selectedChainId, '');
      _setRequiredNamespaces({});
      await disconnect();
      return;
    }

    // Store the chain for when we reload the app.
    await storageService.instance.setString(selectedChainId, chainInfo.chainId);

    // TODO all this logic about switching chain seems odd. A full test has to be done.
    final hasValidSession = isConnected && _currentSession != null;
    if (switchChain && hasValidSession && _currentSelectedChain != null) {
      final hasSwitchMethod = NamespaceUtils.getNamespacesMethodsForChainId(
        chainId: _currentSelectedChain!.namespace,
        namespaces: _currentSession!.namespaces,
      ).contains(EthUtil.walletSwitchEthChain);
      final hasChainAlready = !NamespaceUtils.getChainIdsFromNamespaces(
        namespaces: _currentSession!.namespaces,
      ).contains(chainInfo.namespace);
      final chainIsDifferent =
          _currentSelectedChain!.chainId != chainInfo.chainId;
      if (hasSwitchMethod && !hasChainAlready && chainIsDifferent) {
        // Then we swap/add the chain and launch the wallet
        _switchEthChain(_currentSelectedChain!, chainInfo);
        await launchConnectedWallet();
      }
    }

    _currentSelectedChain = chainInfo;
    // Get the token/chain icon
    _tokenImageUrl = _getTokenImage(chainInfo);

    // Set the requiredNamespace to be the selected chain
    // This will also notify listeners
    _setRequiredNamespaces(_currentSelectedChain!.requiredNamespaces);

    W3MLoggerUtil.logger.t('[$runtimeType] setSelectedChain success');
    _loadAccountData();
  }

  String _getTokenImage(W3MChainInfo chainInfo) {
    if (chainInfo.chainIcon != null && chainInfo.chainIcon!.contains('http')) {
      return chainInfo.chainIcon!;
    }
    final chainImageId = AssetUtil.getChainIconId(chainInfo.chainId);
    return explorerService.instance!.getAssetImageUrl(chainImageId);
  }

  @override
  Future<void> openModal(BuildContext context, [Widget? startWidget]) async {
    _checkInitialized();

    if (_isOpen) {
      return;
    }

    _isOpen = true;

    // Reset the explorer
    explorerService.instance!.search(query: '');
    widgetStack.instance.clear();

    _context = context;

    final isBottomSheet = platformUtils.instance.isBottomSheet();

    final theme = Web3ModalTheme.maybeOf(_context!);
    final childWidget = theme == null
        ? Web3ModalTheme(
            themeData: const Web3ModalThemeData(),
            child: Web3Modal(startWidget: startWidget),
          )
        : Web3Modal(startWidget: startWidget);

    final rootWidget = Web3ModalProvider(
      service: this,
      child: childWidget,
    );

    final data = MediaQueryData.fromView(View.of(_context!));
    final isTabletSize = data.size.shortestSide < 600 ? false : true;

    if (isBottomSheet) {
      await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
        elevation: 0.0,
        useRootNavigator: true,
        constraints: isTabletSize
            ? const BoxConstraints(
                maxWidth: 360.0,
                maxHeight: 600.0,
              )
            : null,
        context: _context!,
        builder: (_) => rootWidget,
      );
    } else {
      await showDialog(
        useRootNavigator: true,
        context: _context!,
        builder: (_) => rootWidget,
      );
    }

    _isOpen = false;

    _notify();
  }

  @override
  Future<void> expirePreviousInactivePairings() async {
    for (var pairing in _web3App!.pairings.getAll()) {
      if (!pairing.active) {
        await _web3App!.core.expirer.expire(pairing.topic);
      }
    }
  }

  @override
  Future<void> buildConnectionUri() async {
    // If we aren't connected, connect!
    if (!_isConnected) {
      W3MLoggerUtil.logger.t(
        '[$runtimeType] Connecting to WalletConnect, '
        'required namespaces: $requiredNamespaces, '
        'optional namespaces: $optionalNamespaces',
      );

      if (connectResponse != null) {
        try {
          sessionFuture?.timeout(Duration.zero);
        } catch (_) {
          // Ignore this error, just wanted to cancel the previous future.
        }
      }

      connectResponse = await _web3App!.connect(
        requiredNamespaces: requiredNamespaces,
        optionalNamespaces: optionalNamespaces,
      );

      _notify();

      _awaitConnectResponse();
    }
  }

  @override
  Future<void> connectWallet([W3MWalletInfo? walletInfo]) async {
    _checkInitialized();
    final walletToConnect = _selectedWallet ?? walletInfo;
    if (walletToConnect == null) {
      throw W3MServiceException(
        'You didn\'t select a wallet or walletInfo argument is null',
      );
    }

    if (_connectingWallet) {
      return;
    }
    _connectingWallet = true;

    try {
      await buildConnectionUri();
      await urlUtils.instance.navigateDeepLink(
        nativeLink: walletToConnect.listing.mobileLink,
        universalLink: walletToConnect.listing.webappLink,
        wcURI: wcUri!,
      );
      // Update explorer service with new recent
      explorerService.instance!.updateRecentPosition(
        walletToConnect.listing.id,
      );
    } on LaunchUrlException catch (e, s) {
      W3MLoggerUtil.logger.e('[$runtimeType] error launching wallet $e, $s');
      toastUtils.instance.show(
        ToastMessage(
          type: ToastType.error,
          text: e.message,
        ),
      );
    }

    _connectingWallet = false;
  }

  @override
  Future<void> launchConnectedWallet() async {
    _checkInitialized();

    if (_currentSession == null) {
      return;
    }

    final redirect = _constructRedirect();

    W3MLoggerUtil.logger.t(
      '[$runtimeType] Launching wallet: $redirect, ${_currentSession?.peer.metadata}',
    );

    if (redirect == null) {
      await urlUtils.instance.launchUrl(
        Uri.parse(_currentSession!.peer.metadata.url),
      );
    } else {
      // Get the native and universal URLs and add the 'wc' to the end
      // in the redirect.
      final nativeUrl = coreUtils.instance.createSafeUrl(redirect.native ?? '');
      final universalUrl =
          coreUtils.instance.createPlainUrl(redirect.universal ?? '');

      await urlUtils.instance.launchRedirect(
        nativeUri: Uri.parse(
          '${nativeUrl}wc?sessionTopic=${_currentSession!.topic}',
        ),
        universalUri: Uri.parse(
          '${universalUrl}wc?sessionTopic=${_currentSession!.topic}',
        ),
      );
    }
  }

  @override
  String getReferer() {
    _checkInitialized();

    return _web3App!.metadata.name.replaceAll(' ', '');
  }

  @override
  Future<void> reconnectRelay() async {
    _checkInitialized();

    await _web3App!.core.relayClient.connect();
  }

  @override
  Future<void> disconnect({bool disconnectAllSessions = true}) async {
    _checkInitialized();

    // If we don't have a session, disconnect automatically and notify listeners
    if (_currentSession == null) {
      return _cleanSession();
    }

    // If we want to disconnect all sessions, loop through them and disconnect them
    if (disconnectAllSessions) {
      for (final SessionData session in _web3App!.sessions.getAll()) {
        await _disconnectSession(session);
      }
    } else {
      // Disconnect the session
      await _disconnectSession(_currentSession!);
    }
  }

  @override
  void closeModal() {
    // If we aren't open, then we can't and shouldn't close
    if (!_isOpen) {
      return;
    }

    toastUtils.instance.clear();
    if (_context != null) {
      // _isOpen and notify() are handled when we call Navigator.pop()
      // by the open() method
      Navigator.pop(_context!);
    } else {
      _notify();
    }
  }

  @override
  Future<void> selectWallet({required W3MWalletInfo? walletInfo}) async {
    _selectedWallet = walletInfo;
    return;
  }

  @override
  void launchBlockExplorer() async {
    if (_currentSelectedChain?.blockExplorer != null) {
      final blockExplorer = _currentSelectedChain!.blockExplorer!.url;
      final explorerUrl = '$blockExplorer/address/$address';
      await urlUtils.instance.launchUrl(
        Uri.parse(explorerUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _unregisterListeners();
    }
    super.dispose();
  }

  ////////* PRIVATE METHODS */////////

  void _notify() => notifyListeners();

  void _registerListeners() {
    _web3App!.onSessionConnect.subscribe(onSessionConnect);
    _web3App!.onSessionDelete.subscribe(onSessionDelete);
    _web3App!.core.relayClient.onRelayClientConnect
        .subscribe(onRelayClientConnect);
    _web3App!.core.relayClient.onRelayClientError.subscribe(onRelayClientError);
    _web3App!.onSessionEvent.subscribe(onSessionEvent);
    _web3App!.onSessionUpdate.subscribe(onSessionUpdate);
    _web3App!.core.pairing.onPairingExpire.subscribe(onPairingExpireEvent);
  }

  void _unregisterListeners() {
    _web3App!.onSessionConnect.unsubscribe(onSessionConnect);
    _web3App!.onSessionDelete.unsubscribe(onSessionDelete);
    _web3App!.core.relayClient.onRelayClientConnect
        .unsubscribe(onRelayClientConnect);
    _web3App!.core.relayClient.onRelayClientError
        .unsubscribe(onRelayClientError);
    _web3App!.onSessionEvent.unsubscribe(onSessionEvent);
    _web3App!.onSessionUpdate.unsubscribe(onSessionUpdate);
    _web3App!.core.pairing.onPairingExpire.unsubscribe(onPairingExpireEvent);
  }

  void _setRequiredNamespaces(Map<String, RequiredNamespace> requiredNSpaces) {
    _checkInitialized();
    W3MLoggerUtil.logger
        .i('[$runtimeType] _setRequiredNamespaces $requiredNSpaces');
    _requiredNamespaces = requiredNSpaces;
    _notify();
  }

  void _setOptionalNamespaces(Map<String, RequiredNamespace> optionalNSpaces) {
    _checkInitialized();
    W3MLoggerUtil.logger
        .i('[$runtimeType] _setOptionalNamespaces: $optionalNSpaces');
    _optionalNamespaces = optionalNSpaces;
    _notify();
  }

  /// Loads account balance and avatar.
  /// Returns true if it was able to actually load data (i.e. there is a selected chain and session)
  void _loadAccountData() async {
    // If there is no selected chain or session, stop. No account to load in.
    if (_currentSelectedChain == null || _currentSession == null) {
      return;
    }

    W3MLoggerUtil.logger.t('[$runtimeType] _loadAccountData');
    // Get the chain balance.
    _chainBalance = await ledgerService.instance.getBalance(
      _currentSelectedChain!.rpcUrl,
      address!,
    );

    // Get the avatar, each chainId is just a number in string form.
    try {
      final blockchainId = await blockchainApiUtils.instance!.getIdentity(
        address!,
        int.parse(_currentSelectedChain!.chainId),
      );
      _avatarUrl = blockchainId.avatar;
    } catch (_) {
      W3MLoggerUtil.logger
          .e('[$runtimeType] Couldn\'t load avatar, will use default icon');
    }
    W3MLoggerUtil.logger.t('[$runtimeType] account data laoded');
    _notify();
  }

  Future<void> _switchEthChain(W3MChainInfo from, W3MChainInfo to) async {
    final int chainIdInt = int.parse(to.chainId);
    final String chainHex = chainIdInt.toRadixString(16);
    final String chainId = 'eip155:${from.chainId}';
    _web3App!
        .request(
      topic: _currentSession!.topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: 'wallet_switchEthereumChain',
        params: [
          {
            'chainId': '0x$chainHex',
          },
        ],
      ),
    )
        .catchError(
      (e) {
        _web3App!.request(
          topic: _currentSession!.topic,
          chainId: chainId,
          request: SessionRequestParams(
            method: 'wallet_addEthereumChain',
            params: [
              {
                'chainId': '0x$chainHex',
                'chainName': to.chainName,
                'nativeCurrency': {
                  'name': to.tokenName,
                  'symbol': to.tokenName,
                  'decimals': 18,
                },
                'rpcUrls': [to.rpcUrl],
              },
            ],
          ),
        );
      },
    );
  }

  Future<void> _disconnectSession(SessionData toDisconnect) async {
    // Disconnect both the pairing and session
    await _web3App!.disconnectSession(
      topic: toDisconnect.pairingTopic,
      reason: const WalletConnectError(code: 0, message: 'User disconnected'),
    );
    // Disconnecting the session will produce the onSessionDisconnect callback
    await _web3App!.disconnectSession(
      topic: toDisconnect.topic,
      reason: const WalletConnectError(code: 0, message: 'User disconnected'),
    );

    // As a failsafe (If the session is expired for example), set the session to null and notify listeners
    if (_currentSession != null &&
        _currentSession!.topic == toDisconnect.topic) {
      return _cleanSession();
    }
  }

  void _cleanSession() {
    _isConnected = false;
    _address = '';
    _currentSession = null;
    _notify();
  }

  Redirect? _constructRedirect() {
    if (_currentSession == null) {
      return null;
    }

    final sessionRedirect = _currentSession?.peer.metadata.redirect;
    final explorerRedirect = explorerService.instance?.getRedirect(
      name: _currentSession!.peer.metadata.name,
    );

    if (sessionRedirect == null && explorerRedirect == null) {
      return null;
    }

    // Combine the redirect data from the session and the explorer API.
    // The explorer API is the source of truth.
    return Redirect(
      native: explorerRedirect ?? sessionRedirect?.native,
      universal: explorerRedirect ?? sessionRedirect?.universal,
    );
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw W3MServiceException(
        'W3MService must be initialized before calling this method.',
      );
    }
  }

  /// Waits for the session to connect, and then sets the session and address.
  /// If the session fails to connect, it will show an error toast.
  /// If the session connects, it will close the modal.
  /// If the modal is already closed, it will notify listeners.
  /// If there is no connect response, it will do nothing.
  /// The completion of this method is triggered when the dApp
  /// connects to a wallet.
  Future<void> _awaitConnectResponse() async {
    if (connectResponse == null) {
      return;
    }

    try {
      await connectResponse!.session.future;
    } on TimeoutException {
      W3MLoggerUtil.logger
          .i('[$runtimeType] Rebuilding session, ending future');
      return;
    } catch (e) {
      W3MLoggerUtil.logger.e('[$runtimeType] Error connecting to wallet: $e');
      await toastUtils.instance.show(
        ToastMessage(
          type: ToastType.error,
          text: 'Error Connecting to Wallet',
        ),
      );
      return;
    }
  }
}

extension _W3MServiceListeners on W3MService {
  @protected
  void onSessionConnect(SessionConnect? args) async {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionConnect: $args');
    _isConnected = true;
    _currentSession = args!.session;
    _address = NamespaceUtils.getAccount(
      _currentSession!.namespaces.values.first.accounts.first,
    );

    if (_isOpen) {
      closeModal();
    }

    _loadAccountData();
  }

  @protected
  void onSessionDelete(SessionDelete? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionDelete: $args');
    _isConnected = false;
    _address = '';
    _currentSession = null;
    _notify();
  }

  @protected
  void onRelayClientConnect(EventArgs? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onRelayClientConnect: $args');
    _initError = null;
    _notify();
  }

  @protected
  void onRelayClientError(ErrorEvent? args) {
    W3MLoggerUtil.logger.e('[$runtimeType] onRelayClientError: $args');
    _initError = args?.error;
    _notify();
  }

  @protected
  void onSessionUpdate(SessionUpdate? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionUpdate $args');
  }

  @protected
  void onSessionEvent(SessionEvent? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionEvent $args');
    if (args?.name == EthUtil.chainChanged) {
      if (W3MChainPresets.chains.containsKey('${args?.data}')) {
        final chain = W3MChainPresets.chains['${args?.data}'];
        selectChain(chain);
      }
    }
  }

  @protected
  void onPairingExpireEvent(PairingEvent? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onPairingExpireEvent $args');
    onPairingExpire.broadcast();
  }
}
