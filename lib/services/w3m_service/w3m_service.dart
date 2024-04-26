import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/pages/approve_magic_request_page.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/analytics_service/analytics_service.dart';
import 'package:web3modal_flutter/services/analytics_service/analytics_service_singleton.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/i_coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_events.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service_singleton.dart';
import 'package:web3modal_flutter/services/logger_service/i_logger_service.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_data.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';
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
  String? _lastChainEmitted;

  @override
  String get chainBalance {
    return coreUtils.instance.formatChainBalance(_chainBalance);
  }

  @override
  final balanceNotifier = ValueNotifier<String>('-.--');

  bool _isOpen = false;
  @override
  bool get isOpen => _isOpen;

  bool _isConnected = false;
  @override
  bool get isConnected => _isConnected;

  W3MSession? _currentSession;
  @override
  W3MSession? get session => _currentSession;

  ILoggerService get _logger => loggerService.instance;

  W3MService({
    IWeb3App? web3App,
    String? projectId,
    PairingMetadata? metadata,
    Map<String, W3MNamespace>? requiredNamespaces,
    Map<String, W3MNamespace>? optionalNamespaces,
    Set<String>? featuredWalletIds,
    Set<String>? includedWalletIds,
    Set<String>? excludedWalletIds,
    bool? enableAnalytics,
    bool enableEmail = false,
    LogLevel logLevel = LogLevel.nothing,
  }) {
    if (web3App == null) {
      if (projectId == null) {
        throw ArgumentError(
          'Either a projectId and metadata must be provided or an already created web3App.',
        );
      }
      if (metadata == null) {
        throw ArgumentError(
          'Metada is required when using projectId.',
        );
      }
    }

    loggerService.instance = LoggerService(
      level: logLevel,
      projectId: projectId ?? _web3App.core.projectId,
      debugMode: kDebugMode,
    );

    _web3App = web3App ??
        Web3App(
          core: Core(projectId: projectId!),
          metadata: metadata!,
        );
    _projectId = projectId ?? _web3App.core.projectId;

    _setRequiredNamespaces(requiredNamespaces);
    _setOptionalNamespaces(optionalNamespaces);

    analyticsService.instance = AnalyticsService(
      projectId: _projectId,
      enableAnalytics: enableAnalytics,
    )..init().then((_) {
        analyticsService.instance.sendEvent(ModalLoadedEvent());
      });

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
      web3app: _web3App,
      enabled: enableEmail,
    );
  }

  ////////* PUBLIC METHODS */////////

  bool _serviceInitialized = false;

  @override
  Future<void> init() async {
    _serviceInitialized = false;
    if (!coreUtils.instance.isValidProjectID(_projectId)) {
      loggerService.instance.e(
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

    _registerListeners();

    await storageService.instance.init();
    await networkService.instance.init();
    await explorerService.instance.init();
    if (_initializeCoinbaseSDK) {
      // final isInstalled = await cbIsInstalled();
      // Fetch Coinbase Wallet object to get updated metadata
      final cbWallet = await explorerService.instance.getCoinbaseWalletObject();
      await cbInit(metadata: _web3App.metadata, cbWallet: cbWallet);
    }
    await _web3App.init();

    _currentSession = await _getStoredSession();
    if (_currentSession != null) {
      if (_currentSession!.sessionService.isMagic ||
          _currentSession!.sessionService.isCoinbase) {
        final chainId = _currentSession!.chainId;
        _currentSelectedChain = W3MChainPresets.chains[chainId];
        await _setSesionAndChainData(_currentSession!);
      }
    }
    await magicService.instance.init();

    await expirePreviousInactivePairings();

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
      // final storedSession = await _getStoredSession();
      if (_currentSession != null) {
        if (_currentSession!.sessionService.isCoinbase) {
          final isCbConnected = await cbIsConnected();
          if (!isCbConnected) {
            await _cleanSession();
          }
        } else if (_currentSession!.sessionService.isMagic) {
          // Every time the app gets killed MAgic service will treat the user as disconnected
          // So we will need to treat magic session differently
          // await _storeSession(storedSession);
          final email = _currentSession!.email;
          magicService.instance.setEmail(email);
        } else {
          await _cleanSession();
        }
      } else {
        magicService.instance.disconnect();
      }
    }

    // Get the chainId of the chain we are connected to.
    await _selectChainFromStoredId();

    _serviceInitialized = true;
    _status = W3MServiceStatus.initialized;
    loggerService.instance.i('[$runtimeType] initialized');
    _notify();
  }

  Future<void> _setSesionAndChainData(W3MSession w3mSession) async {
    try {
      await _storeSession(w3mSession);
      final chainId = _currentSelectedChain!.chainId;
      final chainInfo = W3MChainPresets.chains[chainId]!;
      await _setLocalEthChain(chainInfo, logEvent: false);
    } catch (e) {
      _logger.e('[$runtimeType] _setSesionAndChainData error $e');
    }
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
      jsonEncode(_currentSession!.toMap()),
    );
    // _isConnected shoudl probably go at the very end of the connection
    _isConnected = true;
  }

  Future<void> _selectChainFromStoredId() async {
    if (_currentSession != null) {
      final chainId = _savedChainId('')!;
      if (chainId.isNotEmpty && W3MChainPresets.chains.containsKey(chainId)) {
        await selectChain(W3MChainPresets.chains[chainId]!, logEvent: false);
      } else {
        final chainId = _currentSession!.chainId;
        await selectChain(W3MChainPresets.chains[chainId]!, logEvent: false);
      }
    }
  }

  @override
  Future<void> selectChain(
    W3MChainInfo? chainInfo, {
    bool switchChain = false,
    bool logEvent = true,
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
      await magicService.instance.switchNetwork(chainId: chainInfo.chainId);
      onModalNetworkChange.broadcast(ModalNetworkChange(
        chainId: chainInfo.namespace,
      ));
    } else {
      final hasValidSession = _isConnected && _currentSession != null;
      if (switchChain && hasValidSession && _currentSelectedChain != null) {
        final approvedChains = _currentSession!.getApprovedChains() ?? [];
        final hasChainAlready = approvedChains.contains(chainInfo.namespace);
        if (!hasChainAlready) {
          requestSwitchToChain(chainInfo);
          final hasSwitchMethod = _currentSession!.hasSwitchMethod();
          if (hasSwitchMethod) {
            launchConnectedWallet();
          }
        } else {
          await _setLocalEthChain(chainInfo, logEvent: logEvent);
        }
      } else {
        await _setLocalEthChain(chainInfo, logEvent: logEvent);
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

  Future<void> _setLocalEthChain(
    W3MChainInfo chainInfo, {
    bool logEvent = false,
  }) async {
    _logger.i('[$runtimeType] set local chain ${chainInfo.namespace}');
    _currentSelectedChain = chainInfo;
    _notify();
    // Store the chain for when we reload the app.
    // If switchChain is true the store is on [_switchEthChain]
    await storageService.instance.setString(
      StringConstants.selectedChainId,
      _currentSelectedChain!.chainId,
    );
    if (_isConnected && logEvent) {
      final network = chainInfo.chainId;
      analyticsService.instance.sendEvent(SwitchNetworkEvent(network: network));
    }
    if (_lastChainEmitted != chainInfo.namespace && _isConnected) {
      _lastChainEmitted = chainInfo.namespace;
      onModalNetworkChange.broadcast(ModalNetworkChange(
        chainId: _lastChainEmitted!,
      ));
    }
    loadAccountData();
  }

  // This method would be used from a custom button alone
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

  // TODO [W3MService] startWidget parameter should be removed
  @override
  Future<void> openModal(BuildContext context, [Widget? startWidget]) async {
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

    analyticsService.instance.sendEvent(ModalOpenEvent(
      connected: _isConnected,
    ));

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
      _close();
    } else {
      await showDialog(
        barrierDismissible: false,
        useSafeArea: true,
        useRootNavigator: true,
        anchorPoint: Offset(0, 0),
        context: _context!,
        builder: (_) {
          final radiuses = Web3ModalTheme.radiusesOf(_context!);
          final maxRadius = min(radiuses.radiusM, 36.0);
          final borderRadius = BorderRadius.all(Radius.circular(maxRadius));
          return Dialog(
            backgroundColor: Web3ModalTheme.colorsOf(_context!).background125,
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
      _close();
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

  void _trackSelectedWallet(
    WalletRedirect? walletRedirect, {
    bool inBrowser = false,
  }) {
    final walletName = _selectedWallet!.listing.name;
    final event = SelectWalletEvent(
      name: walletName,
      platform: inBrowser ? AnalyticsPlatform.web : AnalyticsPlatform.mobile,
    );
    // if (walletRedirect?.mobileOnly == true) {
    //   event = SelectWalletEvent(
    //     name: walletName,
    //     platform: AnalyticsPlatform.mobile.name,
    //   );
    // }
    // if (walletRedirect?.webOnly == true) {
    //   event = SelectWalletEvent(
    //     name: walletName,
    //     platform: AnalyticsPlatform.web.name,
    //   );
    // }
    analyticsService.instance.sendEvent(event);
  }

  @override
  Future<void> connectSelectedWallet({bool inBrowser = false}) async {
    _checkInitialized();

    final walletRedirect = explorerService.instance.getWalletRedirect(
      selectedWallet,
    );

    if (walletRedirect == null) {
      throw W3MServiceException(
        'You didn\'t select a wallet or walletInfo argument is null',
      );
    }
    _trackSelectedWallet(walletRedirect, inBrowser: inBrowser);

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
          walletRedirect,
          wcURI: wcUri!,
          pType: pType,
        );
      }
    } on LaunchUrlException catch (e) {
      if (e is CanNotLaunchUrl) {
        onModalError.broadcast(WalletNotInstalled());
      } else {
        onModalError.broadcast(ErrorOpeningWallet());
      }
    } catch (e, s) {
      if (e is PlatformException) {
        final installed = _selectedWallet?.installed ?? false;
        if (!installed) {
          onModalError.broadcast(WalletNotInstalled());
        } else {
          onModalError.broadcast(ErrorOpeningWallet());
        }
      } else if (e is W3MCoinbaseException) {
        if (e is W3MCoinbaseNotInstalledException) {
          onModalError.broadcast(WalletNotInstalled());
        } else {
          if (_isUserRejectedError(e)) {
            loggerService.instance.i('[$runtimeType] User declined connection');
            onModalError.broadcast(UserRejectedConnection());
            analyticsService.instance.sendEvent(ConnectErrorEvent(
              message: 'User declined connection',
            ));
          } else {
            onModalError.broadcast(ErrorOpeningWallet());
            analyticsService.instance.sendEvent(ConnectErrorEvent(
              message: e.message,
            ));
          }
        }
      } else if (_isUserRejectedError(e)) {
        loggerService.instance.i('[$runtimeType] User declined connection');
        onModalError.broadcast(UserRejectedConnection());
        analyticsService.instance.sendEvent(ConnectErrorEvent(
          message: 'User declined connection',
        ));
      } else {
        loggerService.instance.e(
          '[$runtimeType] Error connecting wallet',
          error: e,
          stackTrace: s,
        );
        onModalError.broadcast(ErrorOpeningWallet());
      }
    }
  }

  @override
  Future<void> buildConnectionUri() async {
    if (!_isConnected) {
      loggerService.instance.i(
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
      loggerService.instance.t(
        '[$runtimeType] Connected with session ${response.toJson()}',
      );
    } on TimeoutException {
      loggerService.instance.i(
        '[$runtimeType] Rebuilding session, ending future',
      );
      return;
    } on JsonRpcError catch (e, s) {
      if (_isUserRejectedError(e)) {
        loggerService.instance.i('[$runtimeType] User declined connection');
        onModalError.broadcast(UserRejectedConnection());
        analyticsService.instance.sendEvent(ConnectErrorEvent(
          message: 'User declined connection',
        ));
      } else {
        final message = e.message ?? 'Error connecting to wallet';
        loggerService.instance.e(
          '[$runtimeType] $message',
          error: e,
          stackTrace: s,
        );
        analyticsService.instance.sendEvent(ConnectErrorEvent(
          message: message,
        ));
      }
      return await expirePreviousInactivePairings();
    }
  }

  @override
  void launchConnectedWallet() async {
    _checkInitialized();

    final walletInfo = explorerService.instance.getConnectedWallet();
    if (walletInfo == null) {
      // if walletInfo is null could mean that either
      // 1. There's no wallet connected (shouldn't happen)
      // 2. Wallet is connected on another device through qr code
      return;
    }

    final isCoinbase = _currentSession!.sessionService.isCoinbase == true;
    if (walletInfo.isCoinbase || isCoinbase) {
      // Coinbase Wallet is getting launched at every request by it's own SDK
      // SO no need to do it here.
      return;
    }

    if (_currentSession!.sessionService.isMagic) {
      // There's no wallet to launch when connected with Email
      return;
    }

    final metadataRedirect = _currentSession!.peer?.metadata.redirect;

    final walletRedirect = explorerService.instance.getWalletRedirect(
      walletInfo,
    );

    if (walletRedirect == null) {
      return;
    }

    try {
      final link = metadataRedirect?.native ?? metadataRedirect?.universal;
      urlUtils.instance.openRedirect(
        walletRedirect.copyWith(mobile: link),
        pType: platformUtils.instance.getPlatformType(),
      );
    } catch (e) {
      onModalError.broadcast(ErrorOpeningWallet());
    }
  }

  @override
  Future<void> reconnectRelay() async {
    await _web3App.core.relayClient.connect();
  }

  @override
  Future<void> disconnect({bool disconnectAllSessions = true}) async {
    _checkInitialized();

    _status = W3MServiceStatus.initializing;
    _notify();
    if (_currentSession?.sessionService.isCoinbase == true) {
      try {
        await cbResetSession();
      } catch (_) {
        _status = W3MServiceStatus.initialized;
        _notify();
        return;
      }
    }
    if (_currentSession?.sessionService.isMagic == true) {
      final disconnected = await magicService.instance.disconnect();
      if (!disconnected) {
        _status = W3MServiceStatus.initialized;
        _notify();
        return;
      }
    }

    try {
      // If we want to disconnect all sessions, loop through them and disconnect them
      if (disconnectAllSessions) {
        for (final SessionData session in _web3App.sessions.getAll()) {
          await _disconnectSession(session.pairingTopic, session.topic);
        }
      } else {
        // Disconnect the session
        await _disconnectSession(
          _currentSession?.pairingTopic,
          _currentSession?.topic,
        );
      }

      analyticsService.instance.sendEvent(DisconnectSuccessEvent());
      if (!(_currentSession?.sessionService.isWC == true)) {
        // if sessionService.isWC then _cleanSession() is being called on sessionDelete event
        return await _cleanSession();
      }
      return;
    } catch (e) {
      analyticsService.instance.sendEvent(DisconnectErrorEvent());
      _status = W3MServiceStatus.initialized;
      _notify();
    }
  }

  @override
  void closeModal() {
    // If we aren't open, then we can't and shouldn't close
    _close(event: false);
    if (_context != null) {
      Navigator.of(_context!, rootNavigator: true).pop();
      analyticsService.instance.sendEvent(ModalCloseEvent(
        connected: _isConnected,
      ));
    } else {
      _notify();
    }
  }

  void _close({bool event = true}) {
    if (!_isOpen) {
      return;
    }
    _isOpen = false;
    toastUtils.instance.clear();
    if (event) {
      analyticsService.instance.sendEvent(ModalCloseEvent(
        connected: _isConnected,
      ));
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
  Future<List<dynamic>> requestReadContract({
    required DeployedContract deployedContract,
    required String functionName,
    required String rpcUrl,
    List parameters = const [],
  }) async {
    try {
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
      // TODO [W3MService] Support Smart Contract with email if possible
      if (_currentSession!.sessionService.isMagic) {
        throw 'Write to Smart Contract is currently not supported with Email Wallet';
      }
      // TODO [W3MService] Support Smart Contract with Coinbase if possible
      if (_currentSession!.sessionService.isCoinbase) {
        throw 'Write to Smart Contract is currently not supported with Coinbase Wallet';
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
        return await magicService.instance.request(
          chainId: chainId,
          request: request,
        );
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
    } catch (e) {
      if (_isUserRejectedError(e)) {
        loggerService.instance.i('[$runtimeType] User declined request');
        onModalError.broadcast(UserRejectedConnection());
        if (request.method == MethodsConstants.walletSwitchEthChain ||
            request.method == MethodsConstants.walletAddEthChain) {
          rethrow;
        }
        return 'User rejected';
      } else {
        if (e is W3MCoinbaseException) {
          // If the error is due to no session on Coinbase Wallet we disconnnect the session on Modal.
          // This is the only way to detect a missing session since Coinbase Wallet is not sending any event.
          // disconnect();
          throw W3MServiceException('Coinbase Wallet Error');
        }
        rethrow;
      }
    }
  }

  @override
  Future<void> dispose() async {
    if (_status == W3MServiceStatus.initialized) {
      await disconnect();
      await expirePreviousInactivePairings();
      _unregisterListeners();
      _status = W3MServiceStatus.idle;
      loggerService.instance.d('[$runtimeType] dispose');
    }
    super.dispose();
  }

  @override
  final Event<ModalConnect> onModalConnect = Event();

  @override
  final Event<ModalNetworkChange> onModalNetworkChange = Event();

  @override
  final Event<ModalDisconnect> onModalDisconnect = Event();

  @override
  final Event<ModalError> onModalError = Event();

  @override
  final Event<SessionExpire> onSessionExpireEvent = Event();

  @override
  final Event<SessionUpdate> onSessionUpdateEvent = Event();

  @override
  final Event<SessionEvent> onSessionEventEvent = Event();

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
  @override
  Future<void> loadAccountData() async {
    // If there is no selected chain or session, stop. No account to load in.
    if (_currentSelectedChain == null ||
        _currentSession == null ||
        _currentSession?.address == null) {
      return;
    }

    // Get the chain balance.
    _chainBalance = await ledgerService.instance.getBalance(
      _currentSelectedChain!.rpcUrl,
      _currentSession!.address!,
    );
    balanceNotifier.value =
        '$chainBalance ${_currentSelectedChain?.tokenName ?? ''}';

    // Get the avatar, each chainId is just a number in string form.
    try {
      final blockchainId = await blockchainApiUtils.instance!.getIdentity(
        _currentSession!.address!,
        int.parse(_currentSelectedChain!.chainId),
      );
      _avatarUrl = blockchainId.avatar;
      loggerService.instance.i('[$runtimeType] loadAccountData');
    } catch (e) {
      loggerService.instance.e('[$runtimeType] loadAccountData $e');
    }
    _notify();
  }

  @override
  Future<dynamic> requestSwitchToChain(W3MChainInfo newChain) async {
    if (_currentSession?.sessionService.isMagic == true) {
      return selectChain(newChain);
    }
    final chainId = _currentSelectedChain?.chainId;
    final currentChainId = '${StringConstants.namespace}:$chainId';
    final newChainId = '${StringConstants.namespace}:${newChain.chainId}';
    _logger.i('[$runtimeType] requesting switch to chain $newChainId');
    try {
      final response = await request(
        topic: _currentSession?.topic ?? '',
        chainId: currentChainId,
        switchToChainId: newChain.chainId,
        request: SessionRequestParams(
          method: MethodsConstants.walletSwitchEthChain,
          params: [
            {'chainId': newChain.chainHexId}
          ],
        ),
      );
      _currentSelectedChain = newChain;
      await _setSesionAndChainData(_currentSession!);
      return response ?? true;
    } catch (e) {
      _logger.i('[$runtimeType] requesting switchChain error $e');
      // if request errors due to user rejection then set the previous chain
      if (_isUserRejectedError(e)) {
        loggerService.instance.i('[$runtimeType] User declined connection');
        await _setLocalEthChain(_currentSelectedChain!);
        return null;
      } else {
        // Otherwise it meas chain has to be added.
        return await requestAddChain(newChain);
      }
    }
  }

  @override
  Future<dynamic> requestAddChain(W3MChainInfo newChain) async {
    final topic = _currentSession?.topic ?? '';
    final currentId = _currentSelectedChain!.chainId;
    final currentChainId = '${StringConstants.namespace}:$currentId';
    _logger.i('[$runtimeType] requesting add chain ${newChain.namespace}');
    try {
      final response = await request(
        topic: topic,
        chainId: currentChainId,
        switchToChainId: newChain.chainId,
        request: SessionRequestParams(
          method: MethodsConstants.walletAddEthChain,
          params: [newChain.toJson()],
        ),
      );
      _currentSelectedChain = newChain;
      await _setSesionAndChainData(_currentSession!);
      return response ?? true;
    } catch (e) {
      _logger.i('[$runtimeType] requesting addChain error $e');
      await _setLocalEthChain(_currentSelectedChain!);
      return null;
    }
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

  Future<void> _disconnectSession(String? pairingTopic, String? topic) async {
    // Disconnecting the session will produce the onSessionDisconnect callback
    if (topic != null) {
      await _web3App.disconnectSession(
        topic: topic,
        reason: const WalletConnectError(
          code: 0,
          message: 'User disconnected',
        ),
      );
    }
    if (pairingTopic != null) {
      await _web3App.core.pairing.disconnect(topic: pairingTopic);
    }
  }

  Future<void> _cleanSession({SessionDelete? args, bool event = true}) async {
    final walletId = storageService.instance.getString(
      StringConstants.recentWalletId,
    );
    await storageService.instance.clearAll();
    await explorerService.instance.storeRecentWalletId(walletId);
    if (event) {
      onModalDisconnect.broadcast(ModalDisconnect(
        topic: args?.topic,
        id: args?.id,
      ));
    }
    _currentSelectedChain = null;
    _isConnected = false;
    _currentSession = null;
    _lastChainEmitted = null;
    _status = W3MServiceStatus.initialized;
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
    magicService.instance.onMagicConnect.subscribe(_onMagicConnectEvent);
    magicService.instance.onMagicLoginSuccess.subscribe(_onMagicLoginEvent);
    magicService.instance.onMagicError.subscribe(_onMagicErrorEvent);
    magicService.instance.onMagicUpdate.subscribe(_onMagicSessionUpdateEvent);
    magicService.instance.onMagicRpcRequest.subscribe(_onMagicRequest);
    //
    // Coinbase
    onCoinbaseConnect.subscribe(_onCoinbaseConnectEvent);
    onCoinbaseError.subscribe(_onCoinbaseErrorEvent);
    onCoinbaseSessionUpdate.subscribe(_onCoinbaseSessionUpdateEvent);
    //
    _web3App.onSessionConnect.subscribe(_onSessionConnect);
    _web3App.onSessionDelete.subscribe(_onSessionDelete);
    _web3App.onSessionExpire.subscribe(_onSessionExpire);
    _web3App.onSessionUpdate.subscribe(_onSessionUpdate);
    _web3App.onSessionEvent.subscribe(_onSessionEvent);
    // Core
    _web3App.core.relayClient.onRelayClientConnect.subscribe(
      _onRelayClientConnect,
    );
    _web3App.core.relayClient.onRelayClientError.subscribe(
      _onRelayClientError,
    );
    _web3App.core.relayClient.onRelayClientDisconnect.subscribe(
      _onRelayClientDisconnect,
    );
  }

  void _unregisterListeners() {
    // Magic
    magicService.instance.onMagicLoginSuccess.unsubscribe(_onMagicLoginEvent);
    magicService.instance.onMagicError.unsubscribe(_onMagicErrorEvent);
    magicService.instance.onMagicUpdate.unsubscribe(_onMagicSessionUpdateEvent);
    magicService.instance.onMagicRpcRequest.unsubscribe(_onMagicRequest);
    //
    // Coinbase
    onCoinbaseConnect.unsubscribe(_onCoinbaseConnectEvent);
    onCoinbaseError.unsubscribe(_onCoinbaseErrorEvent);
    onCoinbaseSessionUpdate.unsubscribe(_onCoinbaseSessionUpdateEvent);
    //
    _web3App.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3App.onSessionDelete.unsubscribe(_onSessionDelete);
    _web3App.onSessionEvent.unsubscribe(_onSessionEvent);
    _web3App.onSessionUpdate.unsubscribe(_onSessionUpdate);
    // Core
    _web3App.core.relayClient.onRelayClientConnect.unsubscribe(
      _onRelayClientConnect,
    );
    _web3App.core.relayClient.onRelayClientError.unsubscribe(
      _onRelayClientError,
    );
    _web3App.core.relayClient.onRelayClientDisconnect.unsubscribe(
      _onRelayClientDisconnect,
    );
  }

  String? _savedChainId(String? defaultValue) {
    return storageService.instance.getString(
      StringConstants.selectedChainId,
      defaultValue: defaultValue,
    );
  }
}

extension _W3MMagicExtension on W3MService {
  Future<void> _onMagicLoginEvent(MagicLoginEvent? args) async {
    _logger.p('[$runtimeType] _onMagicLoginEvent $args');
    if (args != null) {
      final chainId = args.data?.chainId.toString();
      // final chainId = _savedChainId(args.data?.chainId.toString());
      final newChainId = chainId ?? '1';
      final newChain = W3MChainPresets.chains[chainId]!;
      _currentSelectedChain = newChain;
      final magicData = args.data?.copytWith(chainId: int.tryParse(newChainId));
      final session = W3MSession(magicData: magicData);
      await _setSesionAndChainData(session);
      // magicService.instance.switchNetwork(chainId: newChainId);
      onModalConnect.broadcast(ModalConnect(session));
      if (_isOpen) {
        closeModal();
      }
      if (_selectedWallet == null) {
        storageService.instance.clearKey(StringConstants.recentWalletId);
        storageService.instance.clearKey(StringConstants.connectedWalletData);
      }
    }
  }

  Future<void> _onMagicSessionUpdateEvent(MagicSessionEvent? args) async {
    _logger.p('[$runtimeType] _onMagicUpdateEvent: $args');
    if (args != null) {
      try {
        final newEmail = args.email ?? _currentSession!.email;
        final address = args.address ?? _currentSession!.address!;
        final chainId = args.chainId?.toString() ?? _currentSession!.chainId;
        final newChain = W3MChainPresets.chains[chainId]!;
        _currentSelectedChain = newChain;
        final newData = MagicData(
          email: newEmail,
          address: address,
          chainId: int.parse(chainId),
        );
        final session = _currentSession!.copyWith(magicData: newData);
        await _setSesionAndChainData(session);
      } catch (e, s) {
        _logger.p(
          '[$runtimeType] _onMagicUpdateEvent: $e',
          stackTrace: s,
        );
      }
    }
  }

  Future<void> _onMagicErrorEvent(MagicErrorEvent? args) async {
    _logger.p('[$runtimeType] _onMagicErrorEvent ${args?.error}');
    final errorMessage = args?.error ?? 'Something went wrong';
    if (!errorMessage.toLowerCase().contains('user denied')) {
      onModalError.broadcast(ModalError(errorMessage));
    }
    _notify();
  }

  void _onMagicRequest(MagicRequestEvent? args) {
    _logger.p('[$runtimeType] _onMagicRequest ${args?.toString()}');
    if (args?.result != null) {
      closeModal();
    }
  }

  Future<void> _onMagicConnectEvent(MagicConnectEvent? event) async {
    if (event?.connected == false) {
      if (_currentSession != null) {
        onModalConnect.broadcast(ModalConnect(_currentSession!));
      }
    }
  }
}

extension _W3MCoinbaseExtension on W3MService {
  void _onCoinbaseConnectEvent(CoinbaseConnectEvent? args) async {
    _logger.p('[$runtimeType] _onCoinbaseConnectEvent $args');
    if (args != null) {
      final chainId = _savedChainId(args.data?.chainId.toString());
      final newChainId = chainId ?? '1';
      // final chainId = args.data!.chainId.toString();
      final newChain = W3MChainPresets.chains[newChainId]!;
      _currentSelectedChain = newChain;
      final cbData = args.data?.copytWith(chainId: int.tryParse(newChainId));
      final session = W3MSession(coinbaseData: cbData);
      await _setSesionAndChainData(session);
      onModalConnect.broadcast(ModalConnect(session));
      if (_isOpen) {
        closeModal();
      }
    }
  }

  void _onCoinbaseSessionUpdateEvent(CoinbaseSessionEvent? args) async {
    _logger.p('[$runtimeType] _onCoinbaseSessionUpdateEvent $args');
    if (args != null) {
      try {
        final address = args.address ?? _currentSession!.address!;
        final chainId = args.chainId ?? _currentSession!.chainId;
        final newChain = W3MChainPresets.chains[chainId]!;
        _currentSelectedChain = newChain;
        final newData = CoinbaseData(
          address: address,
          chainName: newChain.chainName,
          chainId: int.parse(chainId),
        );
        final session = _currentSession!.copyWith(coinbaseData: newData);
        await _setSesionAndChainData(session);
      } catch (e, s) {
        _logger.p(
          '[$runtimeType] _onCoinbaseSessionUpdateEvent: $e',
          stackTrace: s,
        );
      }
    }
  }

  void _onCoinbaseErrorEvent(CoinbaseErrorEvent? args) async {
    _logger.p('[$runtimeType] _onCoinbaseErrorEvent ${args?.error}');
    final errorMessage = args?.error ?? 'Something went wrong';
    if (!errorMessage.toLowerCase().contains('user denied')) {
      onModalError.broadcast(ModalError(errorMessage));
    }
  }
}

extension _W3MServiceExtension on W3MService {
  void _onSessionConnect(SessionConnect? args) async {
    _logger.i('[$runtimeType] session connect $args');
    if (args != null) {
      if (_currentSelectedChain == null) {
        final chain = NamespaceUtils.getChainIdsFromNamespaces(
          namespaces: args.session.namespaces,
        ).first;
        final chainId = chain.split(':').last.toString();
        _currentSelectedChain = W3MChainPresets.chains[chainId];
      }
      final session = W3MSession(sessionData: args.session);
      await _setSesionAndChainData(session);
      if (_selectedWallet == null) {
        analyticsService.instance.sendEvent(ConnectSuccessEvent(
          name: 'WalletConnect',
          method: AnalyticsPlatform.qrcode,
        ));
        storageService.instance.clearKey(StringConstants.recentWalletId);
        storageService.instance.clearKey(StringConstants.connectedWalletData);
      } else {
        final walletName = _selectedWallet!.listing.name;
        analyticsService.instance.sendEvent(ConnectSuccessEvent(
          name: walletName,
          method: AnalyticsPlatform.mobile,
        ));
      }
      onModalConnect.broadcast(ModalConnect(session));
      if (_isOpen) {
        closeModal();
      }
    }
  }

  void _onSessionEvent(SessionEvent? args) async {
    _logger.i('[$runtimeType] session event $args');
    onSessionEventEvent.broadcast(args);
    if (args?.name == EventsConstants.chainChanged) {
      final chainId = args?.data.toString() ?? '';
      if (W3MChainPresets.chains.containsKey(chainId)) {
        final newChain = W3MChainPresets.chains[chainId];
        await selectChain(newChain);
      } else {
        _currentSelectedChain = null;
        _notify();
      }
    }
  }

  void _onSessionUpdate(SessionUpdate? args) async {
    _logger.i('[$runtimeType] session update $args');
    if (args != null) {
      final wcSessions = _web3App.sessions.getAll();
      if (wcSessions.isEmpty) return;
      onSessionUpdateEvent.broadcast(args);
      final session = W3MSession(sessionData: wcSessions.first);
      await _setSesionAndChainData(session);
    }
  }

  void _onSessionExpire(SessionExpire? args) {
    _logger.i('[$runtimeType] session expire $args');
    onSessionExpireEvent.broadcast(args);
  }

  void _onSessionDelete(SessionDelete? args) {
    _logger.i('[$runtimeType] session delete $args');
    _cleanSession(args: args);
  }

  void _onRelayClientConnect(EventArgs? args) {
    _logger.i('[$runtimeType] relay client connected');
    final service = _currentSession?.sessionService ?? W3MSessionService.wc;
    if (service.isWC && _serviceInitialized) {
      _status = W3MServiceStatus.initialized;
      _notify();
    }
  }

  void _onRelayClientDisconnect(EventArgs? args) {
    _logger.i('[$runtimeType] relay client disconnected');
    final service = _currentSession?.sessionService ?? W3MSessionService.wc;
    if (service.isWC && _serviceInitialized) {
      _status = W3MServiceStatus.idle;
      _notify();
    }
  }

  void _onRelayClientError(ErrorEvent? args) {
    _logger.i('[$runtimeType] relay client error: $args');
    final service = _currentSession?.sessionService ?? W3MSessionService.wc;
    if (service.isWC) {
      _status = W3MServiceStatus.error;
      _notify();
    }
  }
}
