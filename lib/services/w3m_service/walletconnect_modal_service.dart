import 'dart:async';

import 'package:flutter/material.dart';
import 'package:event/event.dart';
import 'package:w_common/disposable.dart';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'package:web3modal_flutter/constants/namespaces.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_walletconnect_modal_service.dart';
import 'package:web3modal_flutter/services/w3m_service/walletconnect_modal_services.dart';
import 'package:web3modal_flutter/utils/logger.dart';

import 'package:walletconnect_modal_flutter/models/launch_url_exception.dart';
import 'package:walletconnect_modal_flutter/services/utils/core/core_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_message.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/url/url_utils_singleton.dart';

class WalletConnectModalService extends ChangeNotifier
    with Disposable
    implements IWalletConnectModalService {
  bool _isInitialized = false;
  @override
  bool get isInitialized => _isInitialized;

  String _projectId = '';
  @override
  String get projectId => _projectId;

  IWeb3App? _web3App;
  @override
  IWeb3App? get web3App => _web3App;

  dynamic _initError;
  @override
  dynamic get initError => _initError;

  bool _isOpen = false;
  @override
  bool get isOpen => _isOpen;

  bool _isConnected = false;
  @override
  bool get isConnected => _isConnected;

  SessionData? _session;
  @override
  SessionData? get session => _session;

  String? _address;
  @override
  String? get address => _address;

  @override
  String? get wcUri => connectResponse?.uri.toString();

  Map<String, RequiredNamespace> _requiredNamespaces = {};
  @override
  Map<String, RequiredNamespace> get requiredNamespaces => _requiredNamespaces;

  Map<String, RequiredNamespace> _optionalNamespaces =
      NamespaceConstants.ethereum;
  @override
  Map<String, RequiredNamespace> get optionalNamespaces => _optionalNamespaces;

  ConnectResponse? connectResponse;
  Future<SessionData>? get sessionFuture => connectResponse?.session.future;
  BuildContext? context;

  // WalletConnectModalThemeData? _themeData;

  /// Creates a new instance of [WalletConnectModalService].
  /// [web3App] is optional and can be used to pass in an already created [Web3App].
  /// [projectId] and [metadata] are optional and can be used to create a new [Web3App].
  /// You must provide either a [projectId] and [metadata] or an already created [web3App], or this will throw an [ArgumentError].
  /// [requiredNamespaces] is optional and can be used to pass in a custom set of required namespaces.
  /// [explorerService] is optional and can be used to pass in a custom [IExplorerService].
  /// [recommendedWalletIds] is optional and can be used to pass in a custom set of recommended wallet IDs.
  /// [excludedWalletState] is optional and can be used to pass in a custom [ExcludedWalletState].
  /// [excludedWalletIds] is optional and can be used to pass in a custom set of excluded wallet IDs.
  WalletConnectModalService({
    IWeb3App? web3App,
    String? projectId,
    PairingMetadata? metadata,
    Map<String, RequiredNamespace>? requiredNamespaces,
    Map<String, RequiredNamespace>? optionalNamespaces,
    Set<String>? recommendedWalletIds,
    ExcludedWalletState excludedWalletState = ExcludedWalletState.list,
    Set<String>? excludedWalletIds,
  }) {
    if (web3App == null && projectId == null && metadata == null) {
      throw ArgumentError(
        'Either a projectId and metadata must be provided or an already created web3App.',
      );
    }
    _web3App = web3App ??
        Web3App(
          core: Core(
            projectId: projectId!,
          ),
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
      recommendedWalletIds: recommendedWalletIds,
      excludedWalletState: excludedWalletState,
      excludedWalletIds: excludedWalletIds,
    );
  }

  @override
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    registerListeners();

    _initError = null;
    try {
      await _web3App!.init();
    } catch (e, s) {
      debugPrint('WalletConnectModalService _web3App!.init() error $e, $s');
    }

    if (_web3App!.sessions.getAll().isNotEmpty) {
      _isConnected = true;
      _session = _web3App!.sessions.getAll().first;
      _address = NamespaceUtils.getAccount(
        _session!.namespaces.values.first.accounts.first,
      );
    }

    try {
      await WalletConnectModalServices.init();
    } catch (e, s) {
      debugPrint(
          'WalletConnectModalService WalletConnectModalServices.init() error $e, $s');
    }

    _isInitialized = true;
    LoggerUtil.logger.i('WalletConnectModalService initialized');
    notifyListeners();
  }

  @override
  // ignore: prefer_void_to_null
  Future<Null> onDispose() async {
    if (_isInitialized) {
      unregisterListeners();
    }
  }

  @override
  Future<void> open({
    required BuildContext context,
    Widget? startWidget,
  }) async {
    debugPrint('WalletConnectModalService open()');
    // checkInitialized();

    // if (_isOpen) {
    //   return;
    // }

    // _isOpen = true;

    // rebuildConnectionUri();

    // // Reset the explorer
    // explorerService.instance!.filterList(
    //   query: '',
    // );
    // widgetStack.instance.clear();

    // this.context = context;

    // final bool bottomSheet = platformUtils.instance.isBottomSheet();

    // notifyListeners();

    // final WalletConnectModalTheme? theme =
    //     WalletConnectModalTheme.maybeOf(context);
    // final Widget w = theme == null
    //     ? WalletConnectModalTheme(
    //         data: WalletConnectModalThemeData.lightMode,
    //         child: WalletConnectModal(
    //           startWidget: startWidget,
    //         ),
    //       )
    //     : WalletConnectModal(
    //         startWidget: startWidget,
    //       );
    // final Widget root = WalletConnectModalProvider(
    //   service: this,
    //   child: w,
    // );

    // if (bottomSheet) {
    //   await showModalBottomSheet(
    //     // enableDrag: false,
    //     backgroundColor: Colors.transparent,
    //     isDismissible: false,
    //     isScrollControlled: true,
    //     enableDrag: false,
    //     constraints: BoxConstraints(
    //       minWidth: MediaQuery.of(context).size.width,
    //     ),
    //     useSafeArea: true,
    //     context: context,
    //     builder: (context) {
    //       return root;
    //     },
    //   );
    // } else {
    //   await showDialog(
    //     context: context,
    //     builder: (context) {
    //       return root;
    //     },
    //   );
    // }

    // _isOpen = false;

    // notifyListeners();
  }

  @override
  void close() {
    // If we aren't open, then we can't and shouldn't close
    if (!_isOpen) {
      return;
    }

    toastUtils.instance.clear();
    if (context != null) {
      // _isOpen and notifyListeners() are handled when we call Navigator.pop()
      // by the open() method
      Navigator.pop(context!);
    } else {
      notifyListeners();
    }
  }

  @override
  Future<void> reconnectRelay() async {
    checkInitialized();

    await web3App!.core.relayClient.connect();
  }

  @override
  Future<void> disconnect({
    bool disconnectAllSessions = true,
  }) async {
    checkInitialized();

    // If we don't have a session, disconnect automatically and notify listeners
    if (_session == null) {
      _isConnected = false;
      _address = '';
      notifyListeners();
      return;
    }

    // If we want to disconnect all sessions, loop through them and disconnect them
    if (disconnectAllSessions) {
      for (final SessionData session in web3App!.sessions.getAll()) {
        await disconnectSession(session);
      }
    } else {
      // Disconnect the session
      await disconnectSession(_session!);
    }
  }

  @override
  Future<void> launchCurrentWallet() async {
    checkInitialized();

    if (_session == null) {
      return;
    }

    final Redirect? redirect = constructRedirect();

    LoggerUtil.logger.i(
      'Launching wallet: $redirect, ${_session?.peer.metadata}',
    );

    if (redirect == null) {
      await urlUtils.instance.launchUrl(
        Uri.parse(
          _session!.peer.metadata.url,
        ),
      );
    } else {
      // Get the native and universal URLs and add the 'wc' to the end
      // in the redirect.
      final String nativeUrl =
          coreUtils.instance.createSafeUrl(redirect.native ?? '');
      final String universalUrl =
          coreUtils.instance.createPlainUrl(redirect.universal ?? '');

      await urlUtils.instance.launchRedirect(
        nativeUri: Uri.parse(
          '${nativeUrl}wc?sessionTopic=${_session!.topic}',
        ),
        universalUri: Uri.parse(
          '${universalUrl}wc?sessionTopic=${_session!.topic}',
        ),
      );
    }
  }

  @override
  Future<void> rebuildConnectionUri() async {
    // If we aren't connected, connect!
    if (!_isConnected) {
      LoggerUtil.logger.i(
        'Connecting to WalletConnect, required namespaces: $requiredNamespaces, optional namespaces: $optionalNamespaces',
      );

      if (connectResponse != null) {
        try {
          sessionFuture!.timeout(Duration.zero);
        } on TimeoutException {
          // Ignore this error, just wanted to cancel the previous future.
        }
      }

      connectResponse = await web3App!.connect(
        requiredNamespaces: requiredNamespaces,
        optionalNamespaces: optionalNamespaces,
      );

      notifyListeners();

      awaitConnectResponse();
    }
  }

  bool _connectingWallet = false;

  @override
  Future<void> connectWallet({required W3MWalletInfo walletInfo}) async {
    checkInitialized();

    if (_connectingWallet) {
      return;
    }
    _connectingWallet = true;

    // Set the recent
    await storageService.instance.setString(
      StringConstants.recentWallet,
      walletInfo.listing.id,
    );
    // Update explorer service with new recent
    explorerService.instance!.updateSort();

    try {
      await rebuildConnectionUri();
      await urlUtils.instance.navigateDeepLink(
        nativeLink: walletInfo.listing.mobile.native,
        universalLink: walletInfo.listing.mobile.universal,
        wcURI: wcUri!,
      );
    } on LaunchUrlException catch (e) {
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
  void setRequiredNamespaces({
    required Map<String, RequiredNamespace> requiredNamespaces,
  }) {
    checkInitialized();

    LoggerUtil.logger.i('Setting required namespaces: $requiredNamespaces');

    _requiredNamespaces = requiredNamespaces;

    notifyListeners();
  }

  @override
  void setOptionalNamespaces({
    required Map<String, RequiredNamespace> optionalNamespaces,
  }) {
    checkInitialized();

    LoggerUtil.logger.i('Setting optional namespaces: $optionalNamespaces');

    _optionalNamespaces = optionalNamespaces;

    notifyListeners();
  }

  @override
  String getReferer() {
    checkInitialized();

    return _web3App!.metadata.name.replaceAll(' ', '');
  }

  ////// Private methods //////

  @protected
  Future<void> disconnectSession(SessionData toDisconnect) async {
    // Disconnect both the pairing and session
    await web3App!.disconnectSession(
      topic: toDisconnect.pairingTopic,
      // ignore: prefer_const_constructors
      reason: WalletConnectError(
        code: 0,
        message: 'User disconnected',
      ),
    );
    // Disconnecting the session will produce the onSessionDisconnect callback
    await web3App!.disconnectSession(
      topic: toDisconnect.topic,
      // ignore: prefer_const_constructors
      reason: WalletConnectError(
        code: 0,
        message: 'User disconnected',
      ),
    );

    // As a failsafe (If the session is expired for example), set the session to null and notify listeners
    if (_session != null && session!.topic == toDisconnect.topic) {
      _isConnected = false;
      _address = '';
      _session = null;
      notifyListeners();
    }
  }

  @protected
  Redirect? constructRedirect() {
    if (session == null) {
      return null;
    }

    final Redirect? sessionRedirect = session?.peer.metadata.redirect;
    final Redirect? explorerRedirect = explorerService.instance?.getRedirect(
      name: session!.peer.metadata.name,
    );

    if (sessionRedirect == null && explorerRedirect == null) {
      return null;
    }

    // Combine the redirect data from the session and the explorer API.
    // The explorer API is the source of truth.
    return Redirect(
      native: explorerRedirect?.native ?? sessionRedirect?.native,
      universal: explorerRedirect?.universal ?? sessionRedirect?.universal,
    );
  }

  @protected
  void registerListeners() {
    web3App!.onSessionConnect.subscribe(
      onSessionConnect,
    );
    web3App!.onSessionDelete.subscribe(
      onSessionDelete,
    );
    web3App!.core.relayClient.onRelayClientConnect.subscribe(
      onRelayClientConnect,
    );
    web3App!.core.relayClient.onRelayClientError.subscribe(
      onRelayClientError,
    );
  }

  @protected
  void unregisterListeners() {
    web3App!.onSessionConnect.unsubscribe(
      onSessionConnect,
    );
    web3App!.onSessionDelete.unsubscribe(
      onSessionDelete,
    );
    web3App!.core.relayClient.onRelayClientConnect.unsubscribe(
      onRelayClientConnect,
    );
    web3App!.core.relayClient.onRelayClientError.unsubscribe(
      onRelayClientError,
    );
  }

  @protected
  void onSessionConnect(SessionConnect? args) {
    LoggerUtil.logger.i('_onSessionConnect: ${args?.session}');
    _isConnected = true;
    _session = args!.session;
    _address = NamespaceUtils.getAccount(
      _session!.namespaces.values.first.accounts.first,
    );

    if (_isOpen) {
      close();
    } else {
      notifyListeners();
    }
  }

  @protected
  void onSessionDelete(SessionDelete? args) {
    LoggerUtil.logger.i('_onSessionDelete: $args');
    _isConnected = false;
    _address = '';
    _session = null;

    notifyListeners();
  }

  @protected
  void onRelayClientConnect(EventArgs? args) {
    LoggerUtil.logger.i('_onRelayClientConnect: $args');
    _initError = null;

    notifyListeners();
  }

  @protected
  void onRelayClientError(ErrorEvent? args) {
    LoggerUtil.logger.e('_onRelayClientError: ${args?.error}');
    _initError = args?.error;

    notifyListeners();
  }

  /// Waits for the session to connect, and then sets the session and address.
  /// If the session fails to connect, it will show an error toast.
  /// If the session connects, it will close the modal.
  /// If the modal is already closed, it will notify listeners.
  /// If there is no connect response, it will do nothing.
  /// The completion of this method is triggered when the dApp
  /// connects to a wallet.
  @protected
  Future<void> awaitConnectResponse() async {
    if (connectResponse == null) {
      return;
    }

    try {
      await connectResponse!.session.future;
    } on TimeoutException {
      LoggerUtil.logger.i('Rebuilding session, ending future');
      return;
    } catch (e) {
      LoggerUtil.logger.e('Error connecting to wallet: $e');
      await toastUtils.instance.show(
        ToastMessage(
          type: ToastType.error,
          text: 'Error Connecting to Wallet',
        ),
      );
      return;
    }
  }

  @protected
  void checkInitialized() {
    if (!isInitialized) {
      throw StateError(
        'Service must be initialized before calling this method.',
      );
    }
  }
}
