import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/pages/approve_magic_request_page.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/i_coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_events.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';
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

    magicService.instance = MagicService(
      projectId: _projectId,
      metadata: _web3App.metadata,
    );

    W3MLoggerUtil.setLogLevel(logLevel, debugMode: true);
  }

  ////////* PUBLIC METHODS */////////

  @override
  Future<void> init() async {
    if (!coreUtils.instance.isValidProjectID(_projectId)) {
      W3MLoggerUtil.logger.e(
        '[$runtimeType] projectId $_projectId is invalid. '
        'Please provide a valid projectId. '
        'https://docs.walletconnect.com/web3modal/flutter/options for details.',
      );
      return;
    }
    if (_status == W3MServiceStatus.initializing ||
        _status == W3MServiceStatus.initialized) {
      return;
    }
    _status = W3MServiceStatus.initializing;

    _notify();

    await Future.wait([
      magicService.instance.init(),
      magicService.instance.initialized(),
    ]);
    await magicService.instance.isConnected();
    await _web3App.init();
    await storageService.instance.init();
    await networkService.instance.init();
    await explorerService.instance.init();
    if (_initializeCoinbaseSDK) {
      final cbWallet = await explorerService.instance.getCoinbaseWalletObject();
      await cbInit(metadata: _web3App.metadata, cbWallet: cbWallet);
    }

    await expirePreviousInactivePairings();

    _registerListeners();

    final wcPairings = _web3App.pairings.getAll();
    final wcSessions = _web3App.sessions.getAll();

    // Loop through all the chain data
    for (final chain in W3MChainPresets.chains.values) {
      for (final event in EventsConstants.allEvents) {
        _web3App.registerEventHandler(
          chainId: chain.namespace,
          event: event,
        );
      }
    }

    // There's a walletconnect session stored
    if (wcSessions.isNotEmpty) {
      await _storeSession(W3MSession(sessionData: wcSessions.first));
      // session should not outlive the pairing
      if (wcPairings.isEmpty) {
        await disconnect();
      }
    } else {
      // Check for other type of sessions stored
      final storedSession = await _getStoredSession();
      if (storedSession != null) {
        W3MLoggerUtil.logger.i(
          '[$runtimeType] Stored Session ${storedSession.sessionService}',
        );
        if (storedSession.sessionService.isCoinbase) {
          final isCbConnected = await cbIsConnected();
          if (isCbConnected) {
            await _storeSession(storedSession);
          } else {
            await _cleanSession();
          }
        } else if (storedSession.sessionService.isMagic) {
          // Every time the app gets killed MAgic service will treat the user as disconnected
          // So we will need to treat magic session differently
          await _storeSession(storedSession);
          final email = storedSession.magicData!.email;
          magicService.instance.setEmail(email);
        } else {
          await _cleanSession();
        }
      } else {
        final connected = await magicService.instance.connected();
        if (connected) {
          await magicService.instance.disconnect();
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
    try {
      await storageService.instance.setString(
        StringConstants.w3mSession,
        jsonEncode(_currentSession!.toJson()),
      );
    } catch (e) {
      W3MLoggerUtil.logger.e('[$runtimeType] store session $e');
    }
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

    if (_currentSession?.sessionService.isMagic == true) {
      magicService.instance.switchNetwork(chainId: chainInfo.chainId);
      _setEthChain(chainInfo);
    } else {
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
  Future<void> openNetworks(BuildContext context) async {
    return _showModalView(
      context,
      SelectNetworkPage(
        onTapNetwork: (info) {
          selectChain(info);
          widgetStack.instance.addDefault();
        },
      ),
    );
  }

  // TODO [Widget? startWidget] parameter should be removed
  @override
  Future<void> openModal(BuildContext context, [Widget? startWidget]) async {
    // , [Widget? startWidget]
    return _showModalView(context, startWidget);
  }

  Future<void> _showModalView(
    BuildContext context, [
    Widget? startWidget,
  ]) async {
    _checkInitialized();

    if (_isOpen) {
      closeModal();
      return;
    }
    _isOpen = true;
    _context = context;

    // Reset the explorer
    explorerService.instance.search(query: null);
    widgetStack.instance.clear();

    final isBottomSheet = platformUtils.instance.isBottomSheet();
    final theme = Web3ModalTheme.maybeOf(_context!);
    final themeData = theme?.themeData ?? const Web3ModalThemeData();
    await magicService.instance.syncTheme(theme);

    Widget? showWidget = startWidget;
    if (_isConnected && showWidget == null) {
      showWidget = const AccountPage();
    }

    final childWidget = theme == null
        ? Web3ModalTheme(
            themeData: themeData,
            child: Web3Modal(startWidget: showWidget),
          )
        : Web3Modal(startWidget: showWidget);

    final rootWidget = Web3ModalProvider(
      service: this,
      child: childWidget,
    );

    final isApprovePage = startWidget is ApproveTransactionPage;
    final isTabletSize = platformUtils.instance.isTablet(_context!);

    if (isBottomSheet && !isTabletSize) {
      final mqData = MediaQueryData.fromView(View.of(_context!));
      final safeGap = mqData.viewPadding.bottom;
      final maxHeight = mqData.size.height - safeGap - 20.0;
      await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isDismissible: !isApprovePage,
        isScrollControlled: true,
        enableDrag: false,
        elevation: 0.0,
        useRootNavigator: true,
        constraints: BoxConstraints(
          maxHeight: isApprovePage ? 600.0 : maxHeight,
        ),
        context: _context!,
        builder: (_) => rootWidget,
      );
    } else {
      await showDialog(
        barrierDismissible: false,
        useSafeArea: true,
        useRootNavigator: true,
        anchorPoint: Offset(0, 0),
        context: _context!,
        builder: (context) {
          final radiuses = Web3ModalTheme.radiusesOf(context);
          final maxRadius = min(radiuses.radiusM, 36.0);
          final borderRadius = BorderRadius.all(Radius.circular(maxRadius));
          return Dialog(
            backgroundColor: Web3ModalTheme.colorsOf(context).background125,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            clipBehavior: Clip.hardEdge,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360.0,
                maxHeight: 600.0,
              ),
              child: rootWidget,
            ),
          );
        },
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

    final selectedWalletRedirect = explorerService.instance.getWalletRedirect(
      selectedWallet,
    );
    if (selectedWalletRedirect == null) {
      throw W3MServiceException(
        'You didn\'t select a wallet or walletInfo argument is null',
      );
    }
    var pType = platformUtils.instance.getPlatformType();
    if (inBrowser) {
      pType = PlatformType.web;
    }
    try {
      if (_selectedWallet!.isCoinbase) {
        await cbGetAccount();
        await explorerService.instance.storeConnectedWallet(_selectedWallet);
      } else {
        await buildConnectionUri();
        await urlUtils.instance.openRedirect(
          selectedWalletRedirect,
          wcURI: wcUri!,
          pType: pType,
        );
      }
    } on LaunchUrlException catch (e) {
      if (e is CanNotLaunchUrl) {
        onWalletConnectionError.broadcast(WalletNotInstalled());
      } else {
        onWalletConnectionError.broadcast(ErrorOpeningWallet());
      }
    } catch (e, s) {
      if (e is PlatformException) {
        final installed = _selectedWallet?.installed ?? false;
        if (!installed) {
          onWalletConnectionError.broadcast(WalletNotInstalled());
        } else {
          onWalletConnectionError.broadcast(ErrorOpeningWallet());
        }
      } else if (e is W3MCoinbaseException) {
        if (e is W3MCoinbaseNotInstalledException) {
          onWalletConnectionError.broadcast(WalletNotInstalled());
        } else {
          if (_isUserRejectedError(e)) {
            W3MLoggerUtil.logger.t('[$runtimeType] User declined connection');
            onWalletConnectionError.broadcast(UserRejectedConnection());
          } else {
            onWalletConnectionError.broadcast(ErrorOpeningWallet());
          }
        }
      } else if (_isUserRejectedError(e)) {
        W3MLoggerUtil.logger.t('[$runtimeType] User declined connection');
        onWalletConnectionError.broadcast(UserRejectedConnection());
      } else {
        W3MLoggerUtil.logger.e(
          '[$runtimeType] Error connecting wallet',
          error: e,
          stackTrace: s,
        );
        onWalletConnectionError.broadcast(ErrorOpeningWallet());
      }
    }
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
      await explorerService.instance.storeConnectedWallet(_selectedWallet);
      W3MLoggerUtil.logger
          .t('[$runtimeType] Connected with session ${response.toJson()}');
    } on TimeoutException {
      W3MLoggerUtil.logger
          .i('[$runtimeType] Rebuilding session, ending future');
      return;
    } on JsonRpcError catch (e, s) {
      if (_isUserRejectedError(e)) {
        W3MLoggerUtil.logger.t('[$runtimeType] User declined connection');
        onWalletConnectionError.broadcast(UserRejectedConnection());
      } else {
        W3MLoggerUtil.logger.e(
          '[$runtimeType] Error connecting to wallet',
          error: e,
          stackTrace: s,
        );
      }
      return await expirePreviousInactivePairings();
    }
  }

  @override
  Future<bool> launchConnectedWallet() async {
    _checkInitialized();

    final walletInfo = explorerService.instance.getConnectedWallet();
    if (walletInfo == null) {
      // if walletInfo is null could mean that either
      // 1. There's no wallet connected (shouldn't happen)
      // 2. Wallet is connected on another device through qr code
      return false;
    }

    if (walletInfo.isCoinbase || _currentSession!.sessionService.isMagic) {
      // Coinbase Wallet is getting launched at every request by it's own SDK
      // SO no need to do it here.
      return false;
    }

    final redirect = explorerService.instance.getWalletRedirect(walletInfo);
    if (redirect == null) {
      return false;
    }

    return await urlUtils.instance.openRedirect(
      redirect,
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

    return await _cleanSession();
  }

  @override
  void closeModal() {
    // If we aren't open, then we can't and shouldn't close
    if (!_isOpen) {
      return;
    }
    _isOpen = false;

    toastUtils.instance.clear();
    if (_context != null) {
      // _isOpen and notify() are handled when we call Navigator.pop()
      // by the open() method
      Navigator.of(_context!, rootNavigator: true).pop();
    } else {
      _notify();
    }
  }

  @override
  void selectWallet(W3MWalletInfo? walletInfo) {
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
  Future<dynamic> requestReadContract({
    required DeployedContract deployedContract,
    required String functionName,
    required String rpcUrl,
    List parameters = const [],
  }) async {
    try {
      // TODO
      if (_currentSession!.sessionService.isMagic) {
        throw 'Smart Contract interactions is currently not supported with Email Login';
      }
      // TODO
      if (_currentSession!.sessionService.isCoinbase) {
        throw 'Smart Contract interactions is currently not supported with Coinbase Wallet';
      }
      return await _web3App.requestReadContract(
        deployedContract: deployedContract,
        functionName: functionName,
        rpcUrl: rpcUrl,
        parameters: parameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> requestWriteContract({
    required String topic,
    required String chainId,
    required String rpcUrl,
    required DeployedContract deployedContract,
    required String functionName,
    required Transaction transaction,
    String? method,
    List parameters = const [],
  }) async {
    try {
      // TODO
      if (_currentSession!.sessionService.isMagic) {
        throw 'Smart Contract interactions is currently not supported with Email Login';
      }
      // TODO
      if (_currentSession!.sessionService.isCoinbase) {
        throw 'Smart Contract interactions is currently not supported with Coinbase Wallet';
      }
      return await _web3App.requestWriteContract(
        topic: topic,
        chainId: chainId,
        rpcUrl: rpcUrl,
        deployedContract: deployedContract,
        functionName: functionName,
        transaction: transaction,
        method: method,
        parameters: parameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> request({
    required String topic,
    required String chainId,
    required SessionRequestParams request,
    String? switchToChainId,
  }) async {
    if (_currentSession == null) {
      throw W3MServiceException('Session is null');
    }
    try {
      if (_currentSession!.sessionService.isMagic) {
        magicService.instance.request(parameters: request.toJson());
        return await magicService.instance.response();
      }
      if (_currentSession!.sessionService.isCoinbase) {
        return await cbRequest(
          chainId: switchToChainId ?? chainId.split(':').last,
          request: request,
        );
      }
      return await _web3App.request(
        topic: topic,
        chainId: chainId,
        request: request,
      );
    } catch (e, s) {
      if (_isUserRejectedError(e)) {
        W3MLoggerUtil.logger.t('[$runtimeType] User declined connection');
        onWalletConnectionError.broadcast(UserRejectedConnection());
        if (request.method == 'wallet_switchEthereumChain' ||
            request.method == 'wallet_addEthereumChain') {
          rethrow;
        }
        return 'User rejected';
      } else {
        W3MLoggerUtil.logger.e(
          '[$runtimeType] request error',
          error: e,
          stackTrace: s,
        );
        // TODO disconnect() if the error is due to no session on Coinbase Wallet.
        // Coinbase Team must add this event for us.
        // disconnect();
        rethrow;
      }
    }
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

  bool get _initializeCoinbaseSDK {
    final cbId = CoinbaseService.coinbaseWalletId;
    final included = (explorerService.instance.includedWalletIds ?? <String>{});
    final excluded = (explorerService.instance.excludedWalletIds ?? <String>{});

    if (included.isNotEmpty) {
      return included.contains(cbId);
    }
    if (excluded.isNotEmpty) {
      return !excluded.contains(cbId);
    }

    return true;
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
        StringConstants.namespace: RequiredNamespace(
          chains:
              W3MChainPresets.chains.values.map((e) => e.namespace).toList(),
          methods: MethodsConstants.allMethods.toSet().toList(),
          events: EventsConstants.allEvents.toSet().toList(),
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
        '${StringConstants.namespace}:${_currentSelectedChain?.chainId}';
    return request(
      topic: topic,
      chainId: currentChainId,
      switchToChainId: newChain.chainId,
      request: SessionRequestParams(
        method: MethodsConstants.walletSwitchEthChain,
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
          W3MLoggerUtil.logger.t('[$runtimeType] User declined connection');
          _setEthChain(_currentSelectedChain!);
        } else {
          // Otherwise it meas chain has to be added.
          request(
            topic: topic,
            chainId: currentChainId,
            request: SessionRequestParams(
              method: MethodsConstants.walletAddEthChain,
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
    if (e is W3MCoinbaseException) {
      final stringError = e.message.toLowerCase();
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

  Future<void> _cleanSession() async {
    if (_currentSession?.sessionService.isCoinbase == true) {
      await cbResetSession();
    }
    if (_currentSession?.sessionService.isMagic == true) {
      await magicService.instance.disconnect();
    }
    final walletId = storageService.instance.getString(
      StringConstants.recentWalletId,
    );
    await storageService.instance.clearAll();
    await explorerService.instance.storeRecentWalletId(walletId);
    _currentSelectedChain = null;
    _isConnected = false;
    _currentSession = null;
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
    // Magic
    magicService.instance.onMagicLoginSuccess.subscribe(onMagicLoginEvent);
    magicService.instance.onMagicError.subscribe(onMagicErrorEvent);
    magicService.instance.onMagicUpdate.subscribe(onMagicSessionEvent);
    magicService.instance.onMagicRpcRequest.subscribe(onMagicRequest);
    //
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
    // Magic
    magicService.instance.onMagicLoginSuccess.unsubscribe(onMagicLoginEvent);
    magicService.instance.onMagicError.unsubscribe(onMagicErrorEvent);
    magicService.instance.onMagicUpdate.unsubscribe(onMagicSessionEvent);
    magicService.instance.onMagicRpcRequest.unsubscribe(onMagicRequest);
    //
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
  Future<void> onMagicLoginEvent(MagicConnectEvent? args) async {
    W3MLoggerUtil.logger
        .t('[$runtimeType] onMagicLogin: ${args?.data?.toJson()}');
    if (args != null) {
      if (_selectedWallet == null) {
        await storageService.instance.clearKey(StringConstants.recentWalletId);
        await storageService.instance.clearKey(
          StringConstants.connectedWalletData,
        );
      }
      final chainId = args.data!.chainId.toString();
      await selectChain(W3MChainPresets.chains[chainId]!);
      await _storeSession(W3MSession(magicData: args.data!));
      if (_isOpen) {
        closeModal();
      }
    }
  }

  @protected
  Future<void> onMagicSessionEvent(MagicSessionEvent? args) async {
    W3MLoggerUtil.logger
        .t('[$runtimeType] onMagicSessionEvent: ${args?.toString()}');
    if (args != null) {
      final magicData = _currentSession!.magicData!.copytWith(
        email: args.email,
        address: args.address,
        chainId: args.chainId,
      );
      final chainId = magicData.chainId.toString();
      await selectChain(W3MChainPresets.chains[chainId]!);
      await _storeSession(W3MSession(magicData: magicData));
    }
  }

  @protected
  Future<void> onMagicErrorEvent(MagicErrorEvent? args) async {
    W3MLoggerUtil.logger.t('[$runtimeType] onMagicErrorEvent: ${args?.error}');
    _notify();
  }

  void onMagicRequest(MagicRequestEvent? args) {
    if (args?.result != null) {
      closeModal();
    }
  }

  @protected
  void onCoinbaseConnectEvent(CoinbaseConnectEvent? args) async {
    W3MLoggerUtil.logger
        .t('[$runtimeType] onCoinbaseConnectEvent: ${args?.data?.toJson()}');
    if (args != null) {
      final eChainId = args.data?.chainId ?? _currentSelectedChain!.chainId;
      final chainInfo =
          W3MChainPresets.chains[eChainId] ?? W3MChainPresets.chains['1']!;
      await selectChain(chainInfo);
      await _storeSession(W3MSession(coinbaseData: args.data));
      if (_isOpen) {
        closeModal();
      }
    }
  }

  @protected
  void onCoinbaseErrorEvent(CoinbaseErrorEvent? args) async {
    final errorMessage = args?.error ?? 'Something went wrong';
    if (!errorMessage.toLowerCase().contains('user denied')) {
      W3MLoggerUtil.logger
          .e('[$runtimeType] onCoinbaseErrorEvent: $errorMessage');
      onWalletConnectionError.broadcast(WalletErrorEvent(errorMessage));
    }
  }

  @protected
  void onCoinbaseSessionUpdateEvent(CoinbaseSessionEvent? args) async {
    W3MLoggerUtil.logger
        .t('[$runtimeType] onCoinbaseSessionUpdateEvent: ${args.toString()}');
    if (args != null) {
      try {
        final eChainId = args.chainId ?? _currentSelectedChain!.chainId;
        final eAddress = args.address ?? _currentSession!.address!;
        final chainInfo =
            W3MChainPresets.chains[eChainId] ?? W3MChainPresets.chains['1']!;
        final cbData = CoinbaseData(
          address: eAddress,
          chainName: chainInfo.chainName,
          chainId: int.parse(chainInfo.chainId),
        );
        await _storeSession(W3MSession(coinbaseData: cbData));
      } catch (e, s) {
        W3MLoggerUtil.logger.e(
          '[$runtimeType] onCoinbaseChainChangedEvent',
          error: e,
          stackTrace: s,
        );
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
      if (_selectedWallet == null) {
        await storageService.instance.clearKey(StringConstants.recentWalletId);
        await storageService.instance
            .clearKey(StringConstants.connectedWalletData);
      }
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
    if (args?.name == EventsConstants.chainChanged) {
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
    _cleanSession();
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
