import 'dart:async';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'package:web3modal_flutter/constants/namespaces.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service_singleton.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
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
  var _projectId = '';

  W3MServiceStatus _status = W3MServiceStatus.idle;
  @override
  W3MServiceStatus get status => _status;

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
  }

  ////////* PUBLIC METHODS */////////

  @override
  Future<void> init() async {
    if (!coreUtils.instance.isValidProjectID(_projectId)) {
      W3MLoggerUtil.logger.e('[$runtimeType] Please provide a valid projectId. '
          'See https://docs.walletconnect.com/web3modal/flutter/options for details.');
      return;
    }
    if (_status == W3MServiceStatus.initializing ||
        _status == W3MServiceStatus.initialized) {
      return;
    }
    _status = W3MServiceStatus.initializing;
    _initError = null;
    _notify();

    await storageService.instance.init();
    await networkService.instance.init();
    await explorerService.instance!.init();

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
      _setSessionValues(currentSessions.first);
      // session should not outlive the pairing
      if (currentPairings.isEmpty) {
        await disconnect();
      }
    }

    // Set the optional namespaces to everything in our asset util.
    final List<String> chainIds = [];
    for (final chain in W3MChainPresets.chains.values) {
      chainIds.add(chain.namespace);
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
    await _selectChainFromStoredId();

    _status = W3MServiceStatus.initialized;
    W3MLoggerUtil.logger.t('[$runtimeType] initialized');
    _notify();
  }

  void _setSessionValues(SessionData sessionData) {
    _isConnected = true;
    _currentSession = sessionData;
    _address = NamespaceUtils.getAccount(
      _currentSession!.namespaces.values.first.accounts.first,
    );
  }

  Future<void> _selectChainFromStoredId() async {
    if (_currentSession != null) {
      final chainId = storageService.instance.getString(
        StringConstants.selectedChainId,
        defaultValue: '',
      )!;
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
  }

  bool get _sessionHasSwitchMethod {
    return NamespaceUtils.getOptionalMethodsForChainId(
      chainId: _currentSelectedChain!.chainId,
      optionalNamespaces: _currentSession!.optionalNamespaces ?? {},
    ).contains(EthUtil.walletSwitchEthChain);
  }

  bool _sessionHasApprovedChain(String namespace) {
    return NamespaceUtils.getChainIdsFromNamespaces(
      namespaces: _currentSession!.namespaces,
    ).contains(namespace);
  }

  bool get _connectedToMetaMask =>
      _currentSession?.peer.metadata.name.toLowerCase().contains('metamask') ??
      false;

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
      _setRequiredNamespaces({});
      await disconnect();
      return;
    }

    final hasValidSession = isConnected && _currentSession != null;
    if (switchChain && hasValidSession && _currentSelectedChain != null) {
      final hasChainAlready = _sessionHasApprovedChain(chainInfo.namespace);
      final differentChain =
          _currentSelectedChain!.chainId != chainInfo.chainId;
      if (!hasChainAlready && differentChain) {
        _switchEthChain(_currentSelectedChain!, chainInfo);
        if (_sessionHasSwitchMethod && _connectedToMetaMask) {
          await launchConnectedWallet();
        }
      } else {
        _setEthChain(chainInfo);
      }
    } else {
      _setEthChain(chainInfo);
    }
  }

  @override
  List<String>? approvedChainsByConnectedWallet() {
    if (_currentSession == null) {
      return null;
    }

    final sessionNamespaces = _currentSession!.namespaces;
    final nsMethods = sessionNamespaces['eip155']?.methods ?? [];
    final nsAccounts = sessionNamespaces['eip155']?.accounts ?? [];

    final supportsAllNetworks = nsMethods.contains(EthUtil.walletAddEthChain);
    final approvedNetworks = NamespaceUtils.getChainsFromAccounts(nsAccounts);

    if (supportsAllNetworks) {
      return null;
    }

    return approvedNetworks;
  }

  void _setEthChain(W3MChainInfo chainInfo) async {
    _currentSelectedChain = chainInfo;
    // Get the token/chain icon
    _tokenImageUrl = _getTokenImage(chainInfo);

    // Store the chain for when we reload the app.
    // If switchChain is true the store is on [_switchEthChain]
    await storageService.instance.setString(
      StringConstants.selectedChainId,
      _currentSelectedChain!.chainId,
    );

    // Set the requiredNamespace to be the selected chain
    // This will also notify listeners
    _setRequiredNamespaces(_currentSelectedChain!.requiredNamespaces);
    _notify();

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
  Future<void> connectSelectedWallet({bool inBrowser = false}) async {
    _checkInitialized();

    if (selectedWalletRedirect == null) {
      throw W3MServiceException(
        'You didn\'t select a wallet or walletInfo argument is null',
      );
    }

    if (_connectingWallet) {
      return;
    }
    _connectingWallet = true;

    var pType = platformUtils.instance.getPlatformType();
    if (inBrowser) {
      pType = PlatformType.web;
    }
    try {
      await buildConnectionUri();
      await urlUtils.instance.openRedirect(
        selectedWalletRedirect!,
        wcURI: wcUri!,
        pType: pType,
      );
    } on LaunchUrlException catch (e) {
      W3MLoggerUtil.logger.e(
        '[$runtimeType] error launching wallet. '
        '${selectedWalletRedirect?.toString()}',
      );
      toastUtils.instance.show(
        ToastMessage(type: ToastType.error, text: e.message),
      );
    } catch (e, s) {
      W3MLoggerUtil.logger.e('[$runtimeType] error launching wallet. $e, $s');
    }

    _connectingWallet = false;
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
          await sessionFuture?.timeout(Duration.zero);
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
      _currentSession = await connectResponse!.session.future;
      _setSessionValues(_currentSession!);
      await _selectChainFromStoredId();
      await explorerService.instance!.updateRecentPosition(
        _selectedWallet?.listing.id,
      );
    } on TimeoutException {
      W3MLoggerUtil.logger
          .i('[$runtimeType] Rebuilding session, ending future');
      return;
    } on JsonRpcError catch (e) {
      W3MLoggerUtil.logger.e('[$runtimeType] Error connecting to wallet: $e');
      final errorMessage = e.message ?? 'Error Connecting to Wallet';
      toastUtils.instance.show(
        ToastMessage(type: ToastType.error, text: errorMessage),
      );
      return await expirePreviousInactivePairings();
    }
  }

  @override
  Future<void> launchConnectedWallet() async {
    _checkInitialized();

    if (sessionWalletRedirect == null) {
      return;
    }

    W3MLoggerUtil.logger.t(
      '[$runtimeType] Launching wallet: $sessionWalletRedirect, ${_currentSession?.peer.metadata}',
    );

    return await urlUtils.instance.openRedirect(
      sessionWalletRedirect!,
      pType: platformUtils.instance.getPlatformType(),
    );
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
  void selectWallet(W3MWalletInfo walletInfo) {
    _selectedWallet = walletInfo;
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
    if (_status == W3MServiceStatus.initialized) {
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
    _web3App!.core.heartbeat.onPulse.subscribe(onHeartbeatPulse);
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
    _web3App!.core.heartbeat.onPulse.unsubscribe(onHeartbeatPulse);
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
    final Map<String, String> params = {'chainId': '0x$chainHex'};
    _web3App!
        .request(
      topic: _currentSession!.topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: EthUtil.walletSwitchEthChain,
        params: [params],
      ),
    )
        .catchError(
      (e, s) {
        if (_isUserRejectedError(e)) {
          return _setEthChain(_currentSelectedChain!);
        }
        _web3App!
            .request(
          topic: _currentSession!.topic,
          chainId: chainId,
          request: SessionRequestParams(
            method: EthUtil.walletAddEthChain,
            params: [
              {
                ...params,
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
        )
            .catchError((e, s) {
          if (_isUserRejectedError(e)) {
            return _setEthChain(_currentSelectedChain!);
          }
        });
      },
    );
  }

  bool _isUserRejectedError(dynamic e) {
    if (e is JsonRpcError) {
      final stringError = e.toJson().toString().toLowerCase();
      final userRejected = stringError.contains('rejected');
      return userRejected;
    }
    return false;
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

  @override
  WalletRedirect? get selectedWalletRedirect {
    final walletName = _selectedWallet?.listing.name;
    if (walletName == null) return null;

    return explorerService.instance?.getWalletRedirectByName(
      walletName,
    );
  }

  WalletRedirect? get sessionWalletRedirect {
    final sessionRedirect = _currentSession?.peer.metadata.redirect;
    if (sessionRedirect == null) {
      return null;
    }

    return WalletRedirect(
      mobile: sessionRedirect.native,
      desktop: sessionRedirect.native,
      web: sessionRedirect.universal,
    );
  }

  void _checkInitialized() {
    if (_status != W3MServiceStatus.initialized &&
        _status != W3MServiceStatus.initializing) {
      throw W3MServiceException(
        'W3MService must be initialized before calling this method.',
      );
    }
  }
}

extension _W3MServiceExtension on W3MService {
  @protected
  void onSessionConnect(SessionConnect? args) async {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionConnect: $args');
    _setSessionValues(args!.session);
    _selectChainFromStoredId();

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
    _status = W3MServiceStatus.initialized;
    _notify();
  }

  @protected
  void onRelayClientError(ErrorEvent? args) {
    W3MLoggerUtil.logger.e('[$runtimeType] onRelayClientError: $args');
    _initError = args?.error;
    _status = W3MServiceStatus.error;
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

  @protected
  void onHeartbeatPulse(EventArgs? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onHeartbeatPulse');
  }
}
