import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/i_coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_events.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/models/w3m_session.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/url/launch_url_exception.dart';
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
class W3MService with ChangeNotifier, CoinbaseService implements IW3MService {
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

  String _wcUri = '';
  @override
  String? get wcUri => _wcUri;

  late IWeb3App _web3App;
  @override
  IWeb3App? get web3App => _web3App;

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

  W3MSession? _currentSession;
  @override
  W3MSession? get session => _currentSession;

  @override
  final Event<PairingEvent> onPairingExpire = Event();

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
    if (web3App == null) {
      if (projectId == null) {
        throw ArgumentError(
          'Either a projectId and metadata must be provided or an already created web3App.',
        );
      }
      if (metadata == null) {
        throw ArgumentError('Metada is required when using projectId.');
      }
    }

    _web3App = web3App ??
        Web3App(
          core: Core(projectId: projectId!),
          metadata: metadata!,
        );
    _projectId = projectId ?? _web3App.core.projectId;

    _setRequiredNamespaces(requiredNamespaces);

    _setOptionalNamespaces(optionalNamespaces);

    explorerService.instance = ExplorerService(
      projectId: _projectId,
      referer: _web3App.metadata.name.replaceAll(' ', ''),
      featuredWalletIds: featuredWalletIds,
      includedWalletIds: includedWalletIds,
      excludedWalletIds: excludedWalletIds,
    );

    blockchainApiUtils.instance = BlockchainApiUtils(
      projectId: _projectId,
    );

    W3MLoggerUtil.setLogLevel(logLevel, debugMode: true);
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

    _notify();

    await _web3App.init();
    await storageService.instance.init();
    await networkService.instance.init();
    await explorerService.instance.init();
    if (explorerService.instance.includeCoinbaseWallet) {
      await cbInit(metadata: _web3App.metadata);
    }

    await expirePreviousInactivePairings();

    _registerListeners();

    final wcPairings = _web3App.pairings.getAll();
    final wcSessions = _web3App.sessions.getAll();

    // Loop through all the chain data
    for (final chain in W3MChainPresets.chains.values) {
      for (final event in EthConstants.allEvents) {
        _web3App.registerEventHandler(
          chainId: chain.namespace,
          event: event,
        );
      }
    }

    if (wcSessions.isNotEmpty) {
      await _storeSession(W3MSession(sessionData: wcSessions.first));
      // session should not outlive the pairing
      if (wcPairings.isEmpty) {
        await disconnect();
      }
    } else {
      final storedSession = await _getStoredSession();
      if (storedSession != null) {
        if (storedSession.sessionService.isCoinbase) {
          final isCbConnected = await cbIsConnected();
          if (isCbConnected) {
            await _storeSession(storedSession);
          } else {
            _clearSession();
          }
        }
      }
    }

    // Get the chainId of the chain we are connected to.
    await _selectChainFromStoredId();

    _status = W3MServiceStatus.initialized;
    W3MLoggerUtil.logger.t('[$runtimeType] initialized');
    _notify();
  }

  Future<W3MSession?> _getStoredSession() async {
    try {
      final sessionString = storageService.instance.getString(
        StringConstants.w3mSession,
        defaultValue: '',
      );
      if (sessionString!.isNotEmpty) {
        return W3MSession.fromJson(jsonDecode(sessionString));
      }
    } catch (e) {
      await storageService.instance.setString(StringConstants.w3mSession, '');
    }
    return null;
  }

  Future<void> _storeSession(W3MSession w3mSession) async {
    _currentSession = w3mSession;
    await storageService.instance.setString(
      StringConstants.w3mSession,
      jsonEncode(_currentSession!.toJson()),
    );
    _isConnected = true;
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
        final chainId = _currentSession!.chainId;
        await selectChain(W3MChainPresets.chains[chainId]!);
      }
    }
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

    final hasValidSession = _isConnected && _currentSession != null;
    if (switchChain && hasValidSession && _currentSelectedChain != null) {
      final approvedChains = _currentSession!.getApprovedChains() ?? [];
      final hasChainAlready = approvedChains.contains(chainInfo.namespace);
      if (!hasChainAlready) {
        _switchToEthChain(chainInfo);
        final hasSwitchMethod = _currentSession!.hasSwitchMethod();
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

  /// Will get the list of available chains to add
  @override
  List<String>? getAvailableChains() {
    // if there's no session or if supportsAddChain method then every chain can be used
    if (_currentSession == null || _currentSession!.hasSwitchMethod()) {
      return null;
    }
    return getApprovedChains();
  }

  /// Will get the list of already approved chains by the wallet (to switch to)
  @override
  List<String>? getApprovedChains() {
    if (_currentSession == null) {
      return null;
    }
    return _currentSession!.getApprovedChains();
  }

  @override
  List<String>? getApprovedMethods() {
    if (_currentSession == null) {
      return null;
    }
    return _currentSession!.getApprovedMethods();
  }

  @override
  List<String>? getApprovedEvents() {
    if (_currentSession == null) {
      return null;
    }
    return _currentSession!.getApprovedEvents();
  }

  void _setEthChain(W3MChainInfo chainInfo) async {
    W3MLoggerUtil.logger.t('[$runtimeType] set chain ${chainInfo.namespace}');
    _currentSelectedChain = chainInfo;

    // Store the chain for when we reload the app.
    // If switchChain is true the store is on [_switchEthChain]
    await storageService.instance.setString(
      StringConstants.selectedChainId,
      _currentSelectedChain!.chainId,
    );

    _notify();
    _loadAccountData();
  }

  @override
  Future<void> openModal(BuildContext context, [Widget? startWidget]) async {
    _checkInitialized();

    if (_isOpen) {
      return;
    }
    _isOpen = true;

    // Reset the explorer
    explorerService.instance.search(query: null);
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
    for (var pairing in _web3App.pairings.getAll()) {
      if (!pairing.active) {
        await _web3App.core.expirer.expire(pairing.topic);
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
      if (_selectedWallet!.isCoinbase) {
        await cbGetAccount();
        await explorerService.instance.storeConnectedWalletData(
          _selectedWallet,
        );
      } else {
        await buildConnectionUri();
        await urlUtils.instance.openRedirect(
          selectedWalletRedirect!,
          wcURI: _wcUri,
          pType: pType,
        );
      }
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
      if (_isUserRejectedError(e)) {
        onWalletConnectionError.broadcast(WalletErrorEvent('rejected'));
      } else {
        W3MLoggerUtil.logger.e('[$runtimeType] error launching wallet. $e, $s');
      }
    }

    _connectingWallet = false;
  }

  @override
  Future<void> buildConnectionUri() async {
    if (!_isConnected) {
      W3MLoggerUtil.logger.t(
        '[$runtimeType] Connecting to WalletConnect, '
        'required namespaces: $_requiredNamespaces, '
        'optional namespaces: $_optionalNamespaces',
      );

      final connectResponse = await _web3App.connect(
        requiredNamespaces: _requiredNamespaces,
        optionalNamespaces: _optionalNamespaces,
      );
      _wcUri = connectResponse.uri?.toString() ?? '';
      _notify();
      _awaitConnectionCallback(connectResponse);
    }
  }

  Future<void> _awaitConnectionCallback(ConnectResponse connectResponse) async {
    try {
      final response = await connectResponse.session.future;
      W3MLoggerUtil.logger
          .t('[$runtimeType] Connected with session ${response.toJson()}');
      await explorerService.instance.storeConnectedWalletData(
        _selectedWallet,
      );
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
      '[$runtimeType] Launching wallet: $sessionWalletRedirect, ${_currentSession?.connectedWalletName}',
    );

    return await urlUtils.instance.openRedirect(
      sessionRedirect,
      pType: platformUtils.instance.getPlatformType(),
    );
  }

  @override
  Future<void> reconnectRelay() async {
    _checkInitialized();

    await _web3App.core.relayClient.connect();
  }

  @override
  Future<void> disconnect({bool disconnectAllSessions = true}) async {
    _checkInitialized();

    // If we want to disconnect all sessions, loop through them and disconnect them
    if (disconnectAllSessions) {
      for (final SessionData session in _web3App.sessions.getAll()) {
        await _disconnectSession(session);
      }
    } else {
      // Disconnect the session
      if (_currentSession?.sessionData != null) {
        await _disconnectSession(_currentSession!.sessionData!);
      }
    }

    return await _clearSession();
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
      final address = _currentSession?.address ?? '';
      final explorerUrl = '$blockExplorer/address/$address';
      await urlUtils.instance.launchUrl(
        Uri.parse(explorerUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Future<dynamic> request({
    required String topic,
    required String chainId,
    String? switchToChainId,
    required SessionRequestParams request,
  }) {
    if (_currentSession == null) {
      throw W3MServiceException('Session is null');
    }
    try {
      if (_currentSession!.sessionService.isCoinbase) {
        return cbRequest(
          chainId: switchToChainId ?? chainId.split(':').last,
          request: request,
        );
      }
      return _web3App.request(
        topic: topic,
        chainId: chainId,
        request: request,
      );
    } catch (e, s) {
      W3MLoggerUtil.logger.e('[$runtimeType] request: $e, $s');
      rethrow;
    }
  }

  @override
  WalletRedirect? get selectedWalletRedirect {
    final listing = _selectedWallet?.listing;
    if (listing == null) return null;

    return explorerService.instance.getWalletRedirect(listing);
  }

  Future<WalletRedirect?> sessionWalletRedirect() async {
    // final metadata = _currentSession?.peer.metadata;
    // final sessionRedirect = metadata?.redirect;
    final sessionRedirect = _currentSession?.getSessionRedirect();
    if (sessionRedirect == null) {
      final walletString = storageService.instance.getString(
        StringConstants.walletData,
      );
      if ((walletString ?? '').isNotEmpty) {
        final walletInfo = W3MWalletInfo.fromJson(jsonDecode(walletString!));
        return explorerService.instance.getWalletRedirect(walletInfo.listing);
      }

      final walletName = _currentSession?.connectedWalletName ?? '';
      if (walletName.isNotEmpty) {
        return await explorerService.instance.tryWalletRedirectByName(
          walletName,
        );
      }
    }

    final nativeLink = sessionRedirect!.native;
    return WalletRedirect(
      mobile: nativeLink,
      desktop: nativeLink,
      web: sessionRedirect.universal,
    );
  }

  @override
  void dispose() {
    if (_status == W3MServiceStatus.initialized) {
      _unregisterListeners();
    }
    super.dispose();
  }

  @override
  Event<SessionConnect> get onSessionConnectEvent => _web3App.onSessionConnect;

  @override
  Event<SessionDelete> get onSessionDeleteEvent => _web3App.onSessionDelete;

  @override
  Event<SessionEvent> get onSessionEventEvent => _web3App.onSessionEvent;

  @override
  Event<SessionExpire> get onSessionExpireEvent => _web3App.onSessionExpire;

  @override
  Event<SessionUpdate> get onSessionUpdateEvent => _web3App.onSessionUpdate;

  ////////* PRIVATE METHODS */////////

  void _notify() => notifyListeners();

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
      _requiredNamespaces = {};
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
          chains:
              W3MChainPresets.chains.values.map((e) => e.namespace).toList(),
          methods: EthConstants.allMethods.toSet().toList(),
          events: EthConstants.allEvents.toSet().toList(),
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
        _currentSession?.address == null) {
      return;
    }

    W3MLoggerUtil.logger.t('[$runtimeType] _loadAccountData');
    // Get the chain balance.
    _chainBalance = await ledgerService.instance.getBalance(
      _currentSelectedChain!.rpcUrl,
      _currentSession!.address!,
    );

    // Get the avatar, each chainId is just a number in string form.
    try {
      final blockchainId = await blockchainApiUtils.instance!.getIdentity(
        _currentSession!.address!,
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
    final topic = _currentSession?.sessionData?.topic ?? '';
    final currentChainId =
        '${EthConstants.namespace}:${_currentSelectedChain?.chainId}';
    return request(
      topic: topic,
      chainId: currentChainId,
      switchToChainId: newChain.chainId,
      request: SessionRequestParams(
        method: EthConstants.walletSwitchEthChain,
        params: [
          {'chainId': newChain.chainHexId}
        ],
      ),
    ).then((_) {
      _setEthChain(newChain);
    }).catchError(
      (e, s) {
        // if request errors due to user rejection then set the previous chain
        if (_isUserRejectedError(e)) {
          _setEthChain(_currentSelectedChain!);
        } else {
          // Otherwise it meas chain has to be added.
          request(
            topic: topic,
            chainId: currentChainId,
            request: SessionRequestParams(
              method: EthConstants.walletAddEthChain,
              params: [newChain.toJson()],
            ),
          ).then((_) {
            _setEthChain(newChain);
          }).catchError((_) {
            _setEthChain(_currentSelectedChain!);
          });
        }
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
    if (e is CoinbaseRPCError) {
      final stringError = e.toJson().toString().toLowerCase();
      final userDenied = stringError.contains('user denied');
      return userDenied;
    }
    return false;
  }

  Future<void> _disconnectSession(SessionData toDisconnect) async {
    // Disconnect both the pairing and session
    await _web3App.disconnectSession(
      topic: toDisconnect.pairingTopic,
      reason: const WalletConnectError(
        code: 0,
        message: 'User disconnected',
      ),
    );
    // Disconnecting the session will produce the onSessionDisconnect callback
    await _web3App.disconnectSession(
      topic: toDisconnect.topic,
      reason: const WalletConnectError(
        code: 0,
        message: 'User disconnected',
      ),
    );
  }

  Future<void> _clearSession() async {
    if (_currentSession?.sessionService.isCoinbase == true) {
      await cbResetSession();
    }
    _currentSelectedChain = null;
    _isConnected = false;
    _currentSession = null;
    await storageService.instance.clearAll();
    _notify();
  }

  void _checkInitialized() {
    if (_status != W3MServiceStatus.initialized &&
        _status != W3MServiceStatus.initializing) {
      throw W3MServiceException(
        'W3MService must be initialized before calling this method.',
      );
    }
  }

  void _registerListeners() {
    // Coinbase
    onCoinbaseConnect.subscribe(onCoinbaseConnectEvent);
    onCoinbaseError.subscribe(onCoinbaseErrorEvent);
    onCoinbaseSessionUpdate.subscribe(onCoinbaseSessionUpdateEvent);
    onCoinbaseResponse.subscribe(onCoinbaseResponseEvent);
    //
    _web3App.onSessionConnect.subscribe(onSessionConnect);
    _web3App.onSessionDelete.subscribe(onSessionDelete);
    _web3App.onSessionEvent.subscribe(onSessionEvent);
    _web3App.onSessionUpdate.subscribe(onSessionUpdate);
    // Core
    _web3App.core.relayClient.onRelayClientConnect.subscribe(
      onRelayClientConnect,
    );
    _web3App.core.relayClient.onRelayClientError.subscribe(
      onRelayClientError,
    );
    _web3App.core.pairing.onPairingExpire.subscribe(
      onPairingExpireEvent,
    );
  }

  void _unregisterListeners() {
    // Coinbase
    onCoinbaseConnect.unsubscribe(onCoinbaseConnectEvent);
    onCoinbaseError.unsubscribe(onCoinbaseErrorEvent);
    onCoinbaseSessionUpdate.unsubscribe(onCoinbaseSessionUpdateEvent);
    onCoinbaseResponse.unsubscribe(onCoinbaseResponseEvent);
    //
    _web3App.onSessionConnect.unsubscribe(onSessionConnect);
    _web3App.onSessionDelete.unsubscribe(onSessionDelete);
    _web3App.onSessionEvent.unsubscribe(onSessionEvent);
    _web3App.onSessionUpdate.unsubscribe(onSessionUpdate);
    // Core
    _web3App.core.relayClient.onRelayClientConnect.unsubscribe(
      onRelayClientConnect,
    );
    _web3App.core.relayClient.onRelayClientError.unsubscribe(
      onRelayClientError,
    );
    _web3App.core.pairing.onPairingExpire.unsubscribe(
      onPairingExpireEvent,
    );
  }
}

extension _W3MServiceExtension on W3MService {
  @protected
  void onCoinbaseConnectEvent(CoinbaseConnectEvent? args) async {
    W3MLoggerUtil.logger
        .t('[$runtimeType] onCoinbaseConnect: ${args?.data?.toJson()}');
    if (args != null) {
      final eChainId = args.data?.chainId ?? _currentSelectedChain!.chainId;
      final chainInfo =
          W3MChainPresets.chains[eChainId] ?? W3MChainPresets.chains['1']!;
      await selectChain(chainInfo);
      await _storeSession(W3MSession(coinbaseData: args.data));
      _loadAccountData();
      if (_isOpen) {
        closeModal();
      }
    }
  }

  @protected
  void onCoinbaseErrorEvent(CoinbaseErrorEvent? args) async {
    W3MLoggerUtil.logger
        .e('[$runtimeType] onCoinbaseErrorEvent: ${args?.error}');
    final message = args?.error ?? 'Something wrong happened';
    onWalletConnectionError.broadcast(WalletErrorEvent(message));
  }

  @protected
  void onCoinbaseSessionUpdateEvent(CoinbaseSessionEvent? args) async {
    W3MLoggerUtil.logger
        .t('[$runtimeType] onCoinbaseSessionEvent: ${args.toString()}');
    if (args != null) {
      final eChainId = args.chainId ?? _currentSelectedChain!.chainId;
      final eAddress = args.address ?? _currentSession!.address!;
      try {
        final chainInfo =
            W3MChainPresets.chains[eChainId] ?? W3MChainPresets.chains['1']!;
        await selectChain(chainInfo);
        final cbData = CoinbaseData(
          address: eAddress,
          chainName: chainInfo.chainName,
          chainId: int.parse(chainInfo.chainId),
        );
        await _storeSession(W3MSession(coinbaseData: cbData));
        _loadAccountData();
      } catch (e) {
        W3MLoggerUtil.logger
            .e('[$runtimeType] onCoinbaseChainChangedEvent: $e');
      }
    }
  }

  @protected
  void onCoinbaseResponseEvent(CoinbaseResponseEvent? args) async {
    W3MLoggerUtil.logger
        .t('[$runtimeType] onCoinbaseResponseEvent: ${args?.data}');
  }

  @protected
  void onSessionConnect(SessionConnect? args) async {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionConnect: $args');
    if (args != null) {
      await _storeSession(W3MSession(sessionData: args.session));
      await _selectChainFromStoredId();
      _loadAccountData();
      if (_isOpen) {
        closeModal();
      }
    }
  }

  @protected
  void onSessionEvent(SessionEvent? args) async {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionEvent $args');
    if (args?.name == EthConstants.chainChanged) {
      final chainId = args?.data.toString() ?? '';
      if (W3MChainPresets.chains.containsKey(chainId)) {
        final chain = W3MChainPresets.chains[chainId];
        await selectChain(chain);
      }
    }
  }

  @protected
  void onSessionUpdate(SessionUpdate? args) async {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionUpdate $args');
    final wcSessions = _web3App.sessions.getAll();
    await _storeSession(W3MSession(sessionData: wcSessions.first));
    _loadAccountData();
  }

  @protected
  void onSessionDelete(SessionDelete? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onSessionDelete: $args');
    _clearSession();
  }

  @protected
  void onRelayClientConnect(EventArgs? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onRelayClientConnect: $args');
    _status = W3MServiceStatus.initialized;
    _notify();
  }

  @protected
  void onRelayClientError(ErrorEvent? args) {
    W3MLoggerUtil.logger.e('[$runtimeType] onRelayClientError: ${args?.error}');
    _status = W3MServiceStatus.error;
    _notify();
  }

  @protected
  void onPairingExpireEvent(PairingEvent? args) {
    W3MLoggerUtil.logger.t('[$runtimeType] onPairingExpireEvent $args');
    onPairingExpire.broadcast();
  }
}
