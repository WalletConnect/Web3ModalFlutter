// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w_common/disposable.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/services/explorer/explorer_service.dart';
import 'package:web3modal_flutter/services/explorer/i_explorer_service.dart';
import 'package:web3modal_flutter/services/toast/toast_message.dart';
import 'package:web3modal_flutter/services/toast/toast_service.dart';
import 'package:web3modal_flutter/services/web3modal/i_web3modal_service.dart';
import 'package:web3modal_flutter/utils/logger_util.dart';
import 'package:web3modal_flutter/utils/namespaces.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/web3modal.dart';

class Web3ModalService extends ChangeNotifier
    with Disposable
    implements IWeb3ModalService {
  bool _isInitialized = false;
  @override
  bool get isInitialized => _isInitialized;

  String _projectId = '';
  @override
  String get projectId => _projectId;

  IWeb3App? _web3App;
  @override
  IWeb3App? get web3App => _web3App;

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

  Set<String> _recommendedWalletIds = {};
  @override
  Set<String> get recommendedWalletIds => _recommendedWalletIds;

  ExcludedWalletState _excludedWalletState = ExcludedWalletState.list;
  @override
  ExcludedWalletState get excludedWalletState => _excludedWalletState;

  Set<String> _excludedWalletIds = {};
  @override
  Set<String> get excludedWalletIds => _excludedWalletIds;

  @override
  late IExplorerService explorerService;

  Map<String, RequiredNamespace> _requiredNamespaces =
      NamespaceConstants.ethereum;
  @override
  Map<String, RequiredNamespace> get requiredNamespaces => _requiredNamespaces;

  ConnectResponse? connectResponse;
  BuildContext? context;
  final ToastService _toastService = ToastService();

  /// Creates a new instance of [Web3ModalService].
  Web3ModalService({
    required IWeb3App web3App,
    IExplorerService? explorerService,
    Map<String, RequiredNamespace>? requiredNamespaces,
  }) {
    _web3App = web3App;
    _projectId = projectId;

    _registerListeners();

    if (requiredNamespaces != null) {
      _requiredNamespaces = requiredNamespaces;
    }

    if (explorerService != null) {
      this.explorerService = explorerService;
    } else {
      this.explorerService = ExplorerService(projectId: _projectId);
    }

    if (_web3App!.sessions.getAll().isNotEmpty) {
      _isConnected = true;
      _session = _web3App!.sessions.getAll().first;
      _address = NamespaceUtils.getAccount(
        _session!.namespaces.values.first.accounts.first,
      );
    }

    _isInitialized = true;

    notifyListeners();
  }

  @override
  // ignore: prefer_void_to_null
  Future<Null> onDispose() async {
    if (_isInitialized) {
      _unregisterListeners();
    }
  }

  @override
  Future<void> open({
    required BuildContext context,
    Web3ModalState? startState,
  }) async {
    _checkInitialized();

    if (_isOpen) {
      return;
    }

    // If we aren't connected, connect!
    if (!_isConnected) {
      LoggerUtil.logger.i(
        'Connecting to WalletConnect, required namespaces: $_requiredNamespaces',
      );
      connectResponse = await web3App!.connect(
        requiredNamespaces: _requiredNamespaces,
      );
      _awaitConnectResponse();
    }

    this.context = context;

    final bool bottomSheet = Util.getPlatformType() == PlatformType.mobile ||
        Util.isMobileWidth(context);

    _isOpen = true;

    notifyListeners();

    if (bottomSheet) {
      await showModalBottomSheet(
        // enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Web3Modal(
            service: this,
            toastService: _toastService,
            startState: startState,
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return Web3Modal(
            service: this,
            toastService: _toastService,
            startState: startState,
          );
        },
      );
    }

    _isOpen = false;

    notifyListeners();
  }

  @override
  void close() {
    if (!_isOpen) {
      return;
    }
    // _isOpen = false;

    if (context != null) {
      Navigator.pop(context!);
    }

    // notifyListeners();
  }

  @override
  Future<void> disconnect() async {
    _checkInitialized();

    await web3App!.disconnectSession(
      topic: session!.topic,
      reason: WalletConnectError(
        code: 0,
        message: 'User disconnected',
      ),
    );
    await web3App!.disconnectSession(
      topic: session!.pairingTopic,
      reason: WalletConnectError(
        code: 0,
        message: 'User disconnected',
      ),
    );
  }

  @override
  void launchCurrentWallet() {
    _checkInitialized();

    if (_session == null) {
      return;
    }

    launchUrl(
      Uri.parse(
        _session!.peer.metadata.url,
      ),
    );
  }

  @override
  void setDefaultChain({
    Web3ModalChains? web3modalChain,
    Map<String, RequiredNamespace>? requiredNamespaces,
  }) {
    _checkInitialized();

    if (web3modalChain != null) {
      switch (web3modalChain) {
        case Web3ModalChains.ethereum:
          _requiredNamespaces = NamespaceConstants.ethereum;
          break;
        case Web3ModalChains.polygon:
          _requiredNamespaces = NamespaceConstants.polygon;
          break;
      }
    }

    if (requiredNamespaces != null) {
      _requiredNamespaces = requiredNamespaces;
    }

    notifyListeners();
  }

  @override
  void setRequiredNamespaces(Map<String, RequiredNamespace> namespaces) {
    _checkInitialized();
    LoggerUtil.logger.i('Setting Required namespaces: $namespaces');

    _requiredNamespaces = namespaces;

    notifyListeners();
  }

  @override
  void setRecommendedWallets(
    Set<String> walletIds,
  ) {
    _checkInitialized();

    _recommendedWalletIds = walletIds;

    notifyListeners();
  }

  @override
  void setExcludedWallets(
    ExcludedWalletState state,
    Set<String> walletIds,
  ) {
    _checkInitialized();

    _excludedWalletState = state;
    _excludedWalletIds = walletIds;

    notifyListeners();
  }

  ////// Private methods //////

  void _registerListeners() {
    // web3App!.onSessionConnect.subscribe(
    //   _onSessionConnect,
    // );
    web3App!.onSessionDelete.subscribe(
      _onSessionDelete,
    );
  }

  void _unregisterListeners() {
    // web3App!.onSessionConnect.unsubscribe(
    //   _onSessionConnect,
    // );
    web3App!.onSessionDelete.unsubscribe(
      _onSessionDelete,
    );
  }

  Future<void> _awaitConnectResponse() async {
    if (connectResponse == null) {
      return;
    }

    try {
      final SessionData session = await connectResponse!.session.future;
      _isConnected = true;
      _session = session;
      _address = NamespaceUtils.getAccount(
        _session!.namespaces.values.first.accounts.first,
      );
      // await _toastService.show(
      //   ToastMessage(
      //     type: ToastType.info,
      //     text: 'Connected to Wallet',
      //   ),
      // );
    } catch (e) {
      LoggerUtil.logger.e('Error connecting to wallet: $e');
      await _toastService.show(
        ToastMessage(
          type: ToastType.error,
          text: 'Error Connecting to Wallet',
        ),
      );
    } finally {
      connectResponse = null;
    }

    if (_isOpen) {
      close();
    } else {
      notifyListeners();
    }
  }

  // void _onSessionConnect(SessionConnect? args) {
  //   LoggerUtil.logger.i('Session connected: $args');
  //   _isConnected = true;
  //   _session = args!.session;
  //   _address = NamespaceUtils.getAccount(
  //     _session!.namespaces.values.first.accounts.first,
  //   );

  //   if (_isOpen) {
  //     close();
  //   } else {
  //     notifyListeners();
  //   }
  // }

  void _onSessionDelete(SessionDelete? args) {
    _isConnected = false;
    _address = '';

    notifyListeners();
  }

  void _checkInitialized() {
    if (!isInitialized) {
      throw Exception(
        'Web3ModalService must be initialized before calling this method.',
      );
    }
  }
}
