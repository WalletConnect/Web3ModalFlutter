import 'dart:async';
import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service_singleton.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/url/launch_url_exception.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils_singleton.dart';
import 'package:web3modal_flutter/services/network_service/network_service_singleton.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/web3modal.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/utils/url/url_utils_singleton.dart';

/// Either a [projectId] and [metadata] must be provided or an already created [web3App].
/// optionalNamespaces is mostly not needed, if you use it, the values set here will override every optionalNamespaces set in evey chain
class W3MService with ChangeNotifier implements IW3MService {
  var _projectId = '';

  BuildContext? _context;

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
  Map<String, RequiredNamespace> _optionalNamespaces = {};

  @override
  bool get hasNamespaces =>
      _requiredNamespaces.isNotEmpty || _optionalNamespaces.isNotEmpty;

  ConnectResponse? connectResponse;
  Future<SessionData>? get sessionFuture => connectResponse?.session.future;
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

  @override
  final Event<WalletErrorEvent> onWalletConnectionError = Event();

  bool _connectingWallet = false;

  W3MService({
    IWeb3App? web3App,
    String? projectId,
    PairingMetadata? metadata,
    Map<String, W3MNamespace>? requiredNamespaces,
    Map<String, W3MNamespace>? optionalNamespaces,
    Set<String>? featuredWalletIds,
    Set<String>? includedWalletIds,
    Set<String>? excludedWalletIds,
    LogLevel logLevel = LogLevel.nothing,
  }) {
    if (web3App == null && metadata == null) {
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

    _setRequiredNamespaces(requiredNamespaces);

    _setOptionalNamespaces(optionalNamespaces);

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

    W3MLoggerUtil.setLogLevel(logLevel);
  }

  ////////* PUBLIC METHODS */////////

  @override
  Future<void> init() async {
    if (!coreUtils.instance.isValidProjectID(_projectId)) {
      W3MLoggerUtil.logger.e(
          '[$runtimeType] projectId $_projectId is invalid. Please provide a valid projectId. '
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

    // Loop through all the chain data
    for (final chain in W3MChainPresets.chains.values) {
      for (final event in EthConstants.allEvents) {
        web3App?.registerEventHandler(
          chainId: chain.namespace,
          event: event,
        );
      }
    }

    if (currentSessions.isNotEmpty) {
      _setSessionValues(currentSessions.first);
      // session should not outlive the pairing
      if (currentPairings.isEmpty) {
        await disconnect();
      }
    }

    // Get the chainId of the chain we are connected to.
    await _selectChainFromStoredId();

    _status = W3MServiceStatus.initialized;
    W3MLoggerUtil.logger.t('[$runtimeType] initialized');
    _notify();
  }

  void _setSessionValues(SessionData sessionData) {
    _isConnected = true;
    _currentSession = sessionData;
    if (_currentSession!.namespaces.isNotEmpty) {
      final accounts = _currentSession!.namespaces.values.first.accounts;
      if (accounts.isNotEmpty) {
        _address = NamespaceUtils.getAccount(accounts.first);
      } else {
        W3MLoggerUtil.logger.e('[$runtimeType] empty accounts');
      }
    } else {
      W3MLoggerUtil.logger.e('[$runtimeType] empty namespaces');
    }
  }

  Future<void> _selectChainFromStoredId() async {
    if (_currentSession != null) {
      final chainId = storageService.instance.getString(
        StringConstants.selectedChainId,
        defaultValue: '',
      )!;
      if (chainId.isNotEmpty && W3MChainPresets.chains.containsKey(chainId)) {
        await selectChain(W3MChainPresets.chains[chainId]!);
      } else {
        final chainIds = NamespaceUtils.getChainIdsFromNamespaces(
          namespaces: _currentSession!.namespaces,
        );
        if (chainIds.isNotEmpty) {
          final chainId = (chainIds..sort()).first.split(':')[1];
          // If we have the chain in our presets, set it as the selected chain
          if (W3MChainPresets.chains.containsKey(chainId)) {
            await selectChain(W3MChainPresets.chains[chainId]!);
          }
        } else {
          await selectChain(W3MChainPresets.chains['1']!);
        }
      }
    }
  }

  bool _sessionHasSwitchMethod() {
    if (_currentSession == null) {
      return false;
    }
    final sessionNamespaces = _currentSession!.namespaces;
    final nsMethods = sessionNamespaces[EthConstants.namespace]?.methods ?? [];
    final supportsAddChain = nsMethods.contains(EthConstants.walletAddEthChain);

    return supportsAddChain;
  }

  bool _sessionHasApprovedChain(String chainId) {
    return NamespaceUtils.getChainIdsFromNamespaces(
      namespaces: _currentSession!.namespaces,
    ).contains(chainId);
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

    // If the chain is null, disconnect and stop.
    if (chainInfo == null) {
      await disconnect();
      return;
    }

    _chainBalance = null;

    final hasValidSession = isConnected && _currentSession != null;
    if (switchChain && hasValidSession && _currentSelectedChain != null) {
      final hasChainAlready = _sessionHasApprovedChain(chainInfo.namespace);
      if (!hasChainAlready) {
        _switchToEthChain(chainInfo);
        final hasSwitchMethod = _sessionHasSwitchMethod();
        if (hasSwitchMethod) {
          await launchConnectedWallet();
        }
      } else {
        _setEthChain(chainInfo);
      }
    } else {
      _setEthChain(chainInfo);
    }
  }

  @protected
  @override
  List<String>? getAvailableChains() {
    // if there's no session or
    // if supportsAddChain method
    // then every chain can be used
    if (_currentSession == null || _sessionHasSwitchMethod()) {
      return null;
    }

    return getApprovedChains();
  }

  @override
  List<String>? getApprovedChains() {
    if (_currentSession == null) {
      return null;
    }
    final sessionNamespaces = _currentSession!.namespaces;
    final accounts = sessionNamespaces[EthConstants.namespace]?.accounts ?? [];
    final approvedChains = NamespaceUtils.getChainsFromAccounts(accounts);

    return approvedChains;
  }

  void _setEthChain(W3MChainInfo chainInfo) async {
    _currentSelectedChain = chainInfo;
    // Get the token/chain icon
    _tokenImageUrl = _getTokenImage(chainInfo);

    _notify();

    // Store the chain for when we reload the app.
    // If switchChain is true the store is on [_switchEthChain]
    await storageService.instance.setString(
      StringConstants.selectedChainId,
      _currentSelectedChain!.chainId,
    );

    W3MLoggerUtil.logger.t('[$runtimeType] set chain ${chainInfo.namespace}');
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
    explorerService.instance!.search(query: null);
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
      if (e.message.toLowerCase() != 'app not installed') {
        toastUtils.instance.show(
          ToastMessage(type: ToastType.error, text: e.message),
        );
      }
      onWalletConnectionError.broadcast(WalletErrorEvent('not installed'));
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
        'required namespaces: $_requiredNamespaces, '
        'optional namespaces: $_optionalNamespaces',
      );

      if (connectResponse != null) {
        try {
          await sessionFuture?.timeout(Duration.zero);
        } catch (_) {
          // Ignore this error, just wanted to cancel the previous future.
        }
      }

      connectResponse = await _web3App!.connect(
        requiredNamespaces: _requiredNamespaces,
        optionalNamespaces: _optionalNamespaces,
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
      await explorerService.instance!.storeConnectedWalletData(_selectedWallet);
    } on TimeoutException {
      W3MLoggerUtil.logger
          .i('[$runtimeType] Rebuilding session, ending future');
      return;
    } on JsonRpcError catch (e) {
      W3MLoggerUtil.logger.e('[$runtimeType] Error connecting to wallet: $e');
      if (_isUserRejectedError(e)) {
        onWalletConnectionError.broadcast(WalletErrorEvent('rejected'));
      }
      return await expirePreviousInactivePairings();
    }
  }

  @override
  Future<void> launchConnectedWallet() async {
    _checkInitialized();

    final sessionRedirect = await sessionWalletRedirect();
    if (sessionRedirect == null) {
      return;
    }

    W3MLoggerUtil.logger.t(
      '[$runtimeType] Launching wallet: $sessionWalletRedirect, ${_currentSession?.peer.metadata}',
    );

    return await urlUtils.instance.openRedirect(
      sessionRedirect,
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

  void _setRequiredNamespaces(Map<String, W3MNamespace>? requiredNSpaces) {
    if (requiredNSpaces != null) {
      // Set the required namespaces declared by the user on W3MService object
      _requiredNamespaces = requiredNSpaces.map(
        (key, value) => MapEntry(
          key,
          RequiredNamespace(
            chains: value.chains ?? [W3MChainPresets.chains['1']!.namespace],
            methods: value.methods,
            events: value.events,
          ),
        ),
      );
    } else {
      // Set the required namespaces to everything in our chain presets
      _requiredNamespaces = {
        EthConstants.namespace: RequiredNamespace(
          methods: EthConstants.requiredMethods,
          chains: [W3MChainPresets.chains['1']!.namespace],
          events: EthConstants.requiredEvents,
        ),
      };
    }
  }

  void _setOptionalNamespaces(Map<String, W3MNamespace>? optionalNSpaces) {
    if (optionalNSpaces != null) {
      // Set the optional namespaces declared by the user on W3MService object
      _optionalNamespaces = optionalNSpaces.map(
        (key, value) => MapEntry(
          key,
          RequiredNamespace(
            chains: value.chains ??
                W3MChainPresets.chains.values.map((e) => e.namespace).toList(),
            methods: value.methods,
            events: value.events,
          ),
        ),
      );
    } else {
      // Set the optional namespaces to everything in our chain presets
      _optionalNamespaces = {
        EthConstants.namespace: RequiredNamespace(
          methods: EthConstants.optionalMethods,
          chains:
              W3MChainPresets.chains.values.map((e) => e.namespace).toList(),
          events: EthConstants.optionalEvents,
        ),
      };
    }
  }

  /// Loads account balance and avatar.
  /// Returns true if it was able to actually load data (i.e. there is a selected chain and session)
  void _loadAccountData() async {
    // If there is no selected chain or session, stop. No account to load in.
    if (_currentSelectedChain == null ||
        _currentSession == null ||
        _address == null) {
      return;
    }

    W3MLoggerUtil.logger.t('[$runtimeType] _loadAccountData');
    // Get the chain balance.
    _chainBalance = await ledgerService.instance.getBalance(
      _currentSelectedChain!.rpcUrl,
      _address!,
    );

    // Get the avatar, each chainId is just a number in string form.
    try {
      final blockchainId = await blockchainApiUtils.instance!.getIdentity(
        _address!,
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

  Future<void> _switchToEthChain(W3MChainInfo newChain) async {
    final chainIdInt = int.parse(newChain.chainId);
    final chainHex = chainIdInt.toRadixString(16);
    final chainId =
        '${EthConstants.namespace}:${_currentSelectedChain!.chainId}';
    final params = {'chainId': '0x$chainHex'};
    return _web3App!
        .request(
          topic: _currentSession!.topic,
          chainId: chainId,
          request: SessionRequestParams(
            method: EthConstants.walletSwitchEthChain,
            params: [params],
          ),
        )
        .then((_) => _setEthChain(newChain))
        .catchError(
      (e, s) {
        // if request errors due to user rejection then set the previous chain
        if (_isUserRejectedError(e)) {
          _setEthChain(_currentSelectedChain!);
        }
        // Otherwise it meas chain has to be added.
        _web3App!
            .request(
              topic: _currentSession!.topic,
              chainId: chainId,
              request: SessionRequestParams(
                method: EthConstants.walletAddEthChain,
                params: [
                  {
                    ...params,
                    'chainName': newChain.chainName,
                    'nativeCurrency': {
                      'name': newChain.tokenName,
                      'symbol': newChain.tokenName,
                      'decimals': 18,
                    },
                    'rpcUrls': [newChain.rpcUrl],
                  },
                ],
              ),
            )
            .then((_) => _setEthChain(newChain))
            .catchError((_) => _setEthChain(_currentSelectedChain!));
      },
    );
  }

  bool _isUserRejectedError(dynamic e) {
    if (e is JsonRpcError) {
      final stringError = e.toJson().toString().toLowerCase();
      final userRejected = stringError.contains('rejected');
      final userDisapproved = stringError.contains('user disapproved');
      return userRejected || userDisapproved;
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

    return _cleanSession();
  }

  void _cleanSession() {
    _currentSelectedChain = null;
    _isConnected = false;
    _address = null;
    _currentSession = null;
    _notify();
  }

  @override
  WalletRedirect? get selectedWalletRedirect {
    final listing = _selectedWallet?.listing;
    if (listing == null) return null;

    return explorerService.instance?.getWalletRedirect(listing);
  }

  Future<WalletRedirect?> sessionWalletRedirect() async {
    final metadata = _currentSession?.peer.metadata;
    final sessionRedirect = metadata?.redirect;
    if (sessionRedirect == null) {
      final walletString = storageService.instance.getString(
        StringConstants.walletData,
      );
      if ((walletString ?? '').isNotEmpty) {
        final walletInfo = W3MWalletInfo.fromJson(jsonDecode(walletString!));
        return explorerService.instance!.getWalletRedirect(walletInfo.listing);
      }

      return await explorerService.instance?.tryWalletRedirectByName(
        metadata?.name,
      );
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
    _loadAccountData();
    if (_isOpen) {
      closeModal();
    }
  }

  @protected
  void onSessionEvent(SessionEvent? args) async {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionEvent $args');
    if (args?.name == EthConstants.chainChanged) {
      if (W3MChainPresets.chains.containsKey('${args?.data}')) {
        final chain = W3MChainPresets.chains['${args?.data}'];
        await selectChain(chain);
      }
    }
  }

  @protected
  void onSessionDelete(SessionDelete? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionDelete: $args');
    _cleanSession();
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
    W3MLoggerUtil.logger.e('[$runtimeType] onRelayClientError: ${args?.error}');
    _initError = args?.error;
    _status = W3MServiceStatus.error;
    _notify();
  }

  @protected
  void onSessionUpdate(SessionUpdate? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionUpdate $args');
    _notify();
  }

  @protected
  void onPairingExpireEvent(PairingEvent? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onPairingExpireEvent $args');
    onPairingExpire.broadcast();
  }
}
