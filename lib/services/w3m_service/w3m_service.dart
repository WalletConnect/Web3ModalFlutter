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

    loggerService.instance = LoggerService(level: logLevel, debugMode: true);

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

  @override
  Future<void> init() async {
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

    await _web3App.init();
    await Future.wait([
      magicService.instance.init(),
      magicService.instance.awaitInit(),
    ]);
    await magicService.instance.syncDappData();
    await magicService.instance.isConnected();
    await storageService.instance.init();
    await networkService.instance.init();
    await explorerService.instance.init();
    // await analyticsService.instance.init();
    if (_initializeCoinbaseSDK) {
      // final isInstalled = await cbIsInstalled();
      // Fetch Coinbase Wallet object to get updated metadata
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
        loggerService.instance.i(
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
          final email = storedSession.email!;
          magicService.instance.setEmail(email);
        } else {
          await _cleanSession();
        }
      } else {
        final connected = await magicService.instance.awaitConnected();
        if (connected) {
          await magicService.instance.disconnect();
        }
      }
    }

    // Get the chainId of the chain we are connected to.
    await _selectChainFromStoredId();

    _status = W3MServiceStatus.initialized;
    loggerService.instance.i('[$runtimeType] initialized');
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
      jsonEncode(_currentSession!.toMap()),
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
          _setEthChain(chainInfo, logEvent: logEvent);
        }
      } else {
        _setEthChain(chainInfo, logEvent: logEvent);
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

  void _setEthChain(W3MChainInfo chainInfo, {bool logEvent = false}) async {
    loggerService.instance.i('[$runtimeType] set chain ${chainInfo.namespace}');
    _currentSelectedChain = chainInfo;

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

    _notify();
    loadAccountData();
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
  Future<bool> launchConnectedWallet() async {
    _checkInitialized();

    final walletInfo = explorerService.instance.getConnectedWallet();
    if (walletInfo == null) {
      // if walletInfo is null could mean that either
      // 1. There's no wallet connected (shouldn't happen)
      // 2. Wallet is connected on another device through qr code
      return false;
    }

    if (walletInfo.isCoinbase) {
      // Coinbase Wallet is getting launched at every request by it's own SDK
      // SO no need to do it here.
      return false;
    }

    if (_currentSession!.sessionService.isMagic) {
      // There's no wallet to launch when connected with Email
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
      return await _cleanSession();
    } catch (e) {
      analyticsService.instance.sendEvent(DisconnectErrorEvent());
    }
  }

  @override
  void closeModal() {
    // If we aren't open, then we can't and shouldn't close
    _close(event: false);
    if (_context != null) {
      // _isOpen and notify() are handled when we call Navigator.pop()
      // by the open() method
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
  Future<dynamic> requestReadContract({
    required DeployedContract deployedContract,
    required String functionName,
    required String rpcUrl,
    List parameters = const [],
  }) async {
    try {
      // TODO Support Smart Contract with Magic
      if (_currentSession!.sessionService.isMagic) {
        throw 'Smart Contract interactions is currently not supported with Email Login';
      }
      // TODO Support Smart Contract with Coinbase
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
      // TODO Support Smart Contract with Magic
      if (_currentSession!.sessionService.isMagic) {
        throw 'Smart Contract interactions is currently not supported with Email Login';
      }
      // TODO Support Smart Contract with Coinbase
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
        return await magicService.instance.awaitResponse();
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
  void dispose() async {
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
  final Event<ModalDisconnect> onModalDisconnect = Event();

  @override
  final Event<ModalError> onModalError = Event();

  @Deprecated('Use onModalConnect')
  @override
  Event<SessionConnect> get onSessionConnectEvent => _web3App.onSessionConnect;

  @Deprecated('Use onModalDisconnect')
  @override
  Event<SessionDelete> get onSessionDeleteEvent => _web3App.onSessionDelete;

  @override
  Event<SessionExpire> get onSessionExpireEvent => _web3App.onSessionExpire;

  @override
  Event<SessionUpdate> get onSessionUpdateEvent => _web3App.onSessionUpdate;

  @override
  Event<SessionEvent> get onSessionEventEvent => _web3App.onSessionEvent;

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

  Future<void> _switchToEthChain(W3MChainInfo newChain) async {
    final topic = _currentSession?.topic ?? '';
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
      _setEthChain(newChain, logEvent: true);
    }).catchError(
      (e, s) {
        // if request errors due to user rejection then set the previous chain
        if (_isUserRejectedError(e)) {
          loggerService.instance.i('[$runtimeType] User declined connection');
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
            _setEthChain(newChain, logEvent: true);
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

  Future<void> _disconnectSession(String? pairingTopic, String? topic) async {
    // Disconnect both the pairing and session
    if (pairingTopic != null) {
      await _web3App.disconnectSession(
        topic: pairingTopic,
        reason: const WalletConnectError(
          code: 0,
          message: 'User disconnected',
        ),
      );
    }
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
    magicService.instance.onMagicLoginSuccess.subscribe(_onMagicLoginEvent);
    magicService.instance.onMagicError.subscribe(_onMagicErrorEvent);
    magicService.instance.onMagicUpdate.subscribe(_onMagicUpdateEvent);
    magicService.instance.onMagicRpcRequest.subscribe(_onMagicRequest);
    //
    // Coinbase
    onCoinbaseConnect.subscribe(_onCoinbaseConnectEvent);
    onCoinbaseError.subscribe(_onCoinbaseErrorEvent);
    onCoinbaseSessionUpdate.subscribe(_onCoinbaseSessionUpdateEvent);
    //
    _web3App.onSessionConnect.subscribe(_onSessionConnect);
    _web3App.onSessionDelete.subscribe(_onSessionDelete);
    _web3App.onSessionEvent.subscribe(_onSessionEvent);
    _web3App.onSessionUpdate.subscribe(_onSessionUpdate);
    // Core
    _web3App.core.relayClient.onRelayClientConnect.subscribe(
      _onRelayClientConnect,
    );
    _web3App.core.relayClient.onRelayClientError.subscribe(
      _onRelayClientError,
    );
  }

  void _unregisterListeners() {
    // Magic
    magicService.instance.onMagicLoginSuccess.unsubscribe(_onMagicLoginEvent);
    magicService.instance.onMagicError.unsubscribe(_onMagicErrorEvent);
    magicService.instance.onMagicUpdate.unsubscribe(_onMagicUpdateEvent);
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
  }
}

extension _W3MMagicExtension on W3MService {
  Future<void> _onMagicLoginEvent(MagicConnectEvent? args) async {
    loggerService.instance.i('[$runtimeType] onMagicLoginSuccess $args');
    if (args != null) {
      final session = W3MSession(magicData: args.data);
      await _storeSession(session);
      onModalConnect.broadcast(ModalConnect(session));
      if (_selectedWallet == null) {
        await storageService.instance.clearKey(StringConstants.recentWalletId);
        await storageService.instance.clearKey(
          StringConstants.connectedWalletData,
        );
      }
      final chainId = session.chainId.toString();
      final chainInfo = W3MChainPresets.chains[chainId]!;
      _setEthChain(chainInfo, logEvent: false);
      if (_isOpen) {
        closeModal();
      }
    }
  }

  Future<void> _onMagicUpdateEvent(MagicSessionEvent? args) async {
    loggerService.instance.i('[$runtimeType] onMagicUpdate: $args');
    if (args != null) {
      final newEmail = args.email ?? _currentSession!.email!;
      final newChainId = args.chainId?.toString() ?? _currentSession!.chainId;
      final newAddress = args.address ?? _currentSession!.address!;
      final newSession = _currentSession!.copyWith(
        magicData: MagicData(
          email: newEmail,
          chainId: int.parse(newChainId),
          address: newAddress,
        ),
      );
      await _storeSession(newSession);
      final chainId = newSession.chainId.toString();
      final chainInfo = W3MChainPresets.chains[chainId]!;
      _setEthChain(chainInfo, logEvent: true);
    }
  }

  Future<void> _onMagicErrorEvent(MagicErrorEvent? args) async {
    loggerService.instance.i('[$runtimeType] onMagicError: ${args?.error}');
    _notify();
  }

  void _onMagicRequest(MagicRequestEvent? args) {
    loggerService.instance.i(
      '[$runtimeType] onMagicRpcRequest: ${args?.toString()}',
    );
    if (args?.result != null) {
      closeModal();
    }
  }
}

extension _W3MCoinbaseExtension on W3MService {
  void _onCoinbaseConnectEvent(CoinbaseConnectEvent? args) async {
    loggerService.instance.i('[$runtimeType] onCoinbaseConnect: $args');
    if (args != null) {
      final session = W3MSession(coinbaseData: args.data);
      await _storeSession(session);
      onModalConnect.broadcast(ModalConnect(session));
      final eChainId = session.chainId.toString();
      final chainInfo =
          W3MChainPresets.chains[eChainId] ?? W3MChainPresets.chains['1']!;
      await selectChain(chainInfo);
      if (_isOpen) {
        closeModal();
      }
    }
  }

  void _onCoinbaseErrorEvent(CoinbaseErrorEvent? args) async {
    loggerService.instance.i('[$runtimeType] onCoinbaseError: ${args?.error}');
    final errorMessage = args?.error ?? 'Something went wrong';
    if (!errorMessage.toLowerCase().contains('user denied')) {
      onModalError.broadcast(ModalError(errorMessage));
    }
  }

  void _onCoinbaseSessionUpdateEvent(CoinbaseSessionEvent? args) async {
    loggerService.instance.i('[$runtimeType] onCoinbaseSessionUpdate: $args');
    if (args != null) {
      try {
        final eChainId = args.chainId ?? _currentSelectedChain!.chainId;
        final eAddress = args.address ?? _currentSession!.address!;
        final chainInfo =
            W3MChainPresets.chains[eChainId] ?? W3MChainPresets.chains['1']!;
        final newData = CoinbaseData(
          address: eAddress,
          chainName: chainInfo.chainName,
          chainId: int.parse(chainInfo.chainId),
        );
        await _storeSession(W3MSession(coinbaseData: newData));
      } catch (e, s) {
        loggerService.instance.e(
          '[$runtimeType] onCoinbaseSessionUpdate: $e',
          stackTrace: s,
        );
      }
    }
  }
}

extension _W3MServiceExtension on W3MService {
  void _onSessionConnect(SessionConnect? args) async {
    loggerService.instance.i('[$runtimeType] onSessionConnect: $args');
    if (args != null) {
      final session = W3MSession(sessionData: args.session);
      await _storeSession(session);
      onModalConnect.broadcast(ModalConnect(session));
      if (_selectedWallet == null) {
        // final walletName = args.session.peer.metadata.name;
        analyticsService.instance.sendEvent(ConnectSuccessEvent(
          name: 'WalletConnect',
          method: AnalyticsPlatform.qrcode,
        ));
        await storageService.instance.clearKey(
          StringConstants.recentWalletId,
        );
        await storageService.instance.clearKey(
          StringConstants.connectedWalletData,
        );
      } else {
        // TODO check this logic
        final walletName = _selectedWallet!.listing.name;
        analyticsService.instance.sendEvent(ConnectSuccessEvent(
          name: walletName,
          method: AnalyticsPlatform.mobile,
        ));
      }
      await _selectChainFromStoredId();
      loadAccountData();
      if (_isOpen) {
        closeModal();
      }
    }
  }

  void _onSessionEvent(SessionEvent? args) async {
    loggerService.instance.i('[$runtimeType] onSessionEvent $args');
    if (args?.name == EventsConstants.chainChanged) {
      final chainId = args?.data.toString() ?? '';
      if (W3MChainPresets.chains.containsKey(chainId)) {
        final chain = W3MChainPresets.chains[chainId];
        await selectChain(chain);
      }
    }
  }

  void _onSessionUpdate(SessionUpdate? args) async {
    loggerService.instance.i('[$runtimeType] onSessionUpdate $args');
    final wcSessions = _web3App.sessions.getAll();
    await _storeSession(W3MSession(sessionData: wcSessions.first));
    loadAccountData();
  }

  void _onSessionDelete(SessionDelete? args) {
    loggerService.instance.i('[$runtimeType] onSessionDelete: $args');
    onModalDisconnect.broadcast(ModalDisconnect(
      topic: args?.topic,
      id: args?.id,
    ));
    _cleanSession();
  }

  void _onRelayClientConnect(EventArgs? args) {
    loggerService.instance.i('[$runtimeType] _onRelayClientConnect: $args');
    _status = W3MServiceStatus.initialized;
    _notify();
  }

  void _onRelayClientError(ErrorEvent? args) {
    loggerService.instance.e('[$runtimeType] _onRelayClientError: $args');
    _status = W3MServiceStatus.error;
    _notify();
  }
}
