import 'package:flutter/material.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/widgets/session_widget.dart';
import 'package:walletconnect_flutter_dapp/utils/dart_defines.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.swapTheme});
  final void Function() swapTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IWeb3App? _web3App;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _web3App = await Web3App.createInstance(
      projectId: DartDefines.projectId,
      logLevel: LogLevel.error,
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://web3modal.com/images/rpc-illustration.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );

    _web3App!.onSessionPing.subscribe(_onSessionPing);
    _web3App!.onSessionEvent.subscribe(_onSessionEvent);

    await _web3App!.init();

    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _web3App!.onSessionPing.unsubscribe(_onSessionPing);
    _web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          color: Web3ModalTheme.colorsOf(context).accent100,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Web3ModalTheme.colorsOf(context).background300,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(StringConstants.w3mPageTitleV3),
        backgroundColor: Web3ModalTheme.colorsOf(context).background100,
        foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
        actions: [
          IconButton(
            icon: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
            onPressed: widget.swapTheme,
          ),
        ],
      ),
      body: _W3MPage(web3App: _web3App!),
    );
  }

  void _onSessionPing(SessionPing? args) {
    debugPrint('[$runtimeType] ${StringConstants.receivedPing}: $args');
  }

  void _onSessionEvent(SessionEvent? args) {
    debugPrint('[$runtimeType] ${StringConstants.receivedEvent}: $args');
  }
}

class _W3MPage extends StatefulWidget {
  const _W3MPage({required this.web3App});
  final IWeb3App web3App;

  @override
  State<_W3MPage> createState() => _W3MPageState();
}

class _W3MPageState extends State<_W3MPage> {
  late IWeb3App _web3App;
  late W3MService _w3mService;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _web3App = widget.web3App;
    _web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);

    _initializeService();
  }

  void _initializeService() async {
    // See https://docs.walletconnect.com/web3modal/flutter/custom-chains
    W3MChainPresets.chains.putIfAbsent('42220', () => _exampleCustomChain);

    _w3mService = W3MService(
      web3App: _web3App,
      logLevel: LogLevel.error,
      // There's no need to pass optionalNamespaces rather than to override every other optionalNamespaces configuration in the single chain objects
      // optionalNamespaces: {
      //   'eip155': W3MNamespace(
      //     chains:
      //         W3MChainPresets.chains.values.map((e) => e.namespace).toList(),
      //     methods: [
      //       "eth_accounts",
      //       "eth_requestAccounts",
      //       "eth_sendRawTransaction",
      //       "eth_sign",
      //       "eth_signTransaction",
      //       "eth_signTypedData",
      //       "eth_signTypedData_v3",
      //       "eth_signTypedData_v4",
      //       "eth_sendTransaction",
      //       "personal_sign",
      //       "wallet_switchEthereumChain",
      //       "wallet_addEthereumChain",
      //       "wallet_getPermissions",
      //       "wallet_requestPermissions",
      //       "wallet_registerOnboarding",
      //       "wallet_watchAsset",
      //       "wallet_scanQRCode",
      //     ],
      //     events: [
      //       "chainChanged",
      //       "accountsChanged",
      //       "message",
      //       "disconnect",
      //       "connect",
      //     ],
      //   ),
      // },
    );

    await _w3mService.init();

    _w3mService.addListener(_serviceListener);

    // If you want to support just one chain uncomment this line and avoid using W3MNetworkSelectButton()
    // _w3mService.selectChain(W3MChainPresets.chains['137']);

    setState(() {
      _isConnected = _web3App.sessions.getAll().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _web3App.onSessionConnect.unsubscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.unsubscribe(_onWeb3AppDisconnect);
    super.dispose();
  }

  void _onWeb3AppConnect(SessionConnect? args) {
    setState(() {
      _isConnected = true;
    });
  }

  void _onWeb3AppDisconnect(SessionDelete? args) {
    setState(() {
      _isConnected = false;
    });
  }

  void _serviceListener() {
    debugPrint('_serviceListener');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox.square(dimension: 8.0),
          Visibility(
            visible: !_isConnected,
            child: W3MNetworkSelectButton(service: _w3mService),
          ),
          W3MConnectWalletButton(service: _w3mService),
          const SizedBox.square(dimension: 8.0),
          const Divider(height: 0.0),
          Visibility(
            visible: _isConnected,
            child: _ConnectedView(w3mService: _w3mService),
          ),
        ],
      ),
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(dimension: 12.0),
        W3MAccountButton(service: w3mService),
        SessionWidget(
          session: w3mService.web3App!.sessions.getAll().first,
          web3App: w3mService.web3App!,
          selectedChain: w3mService.selectedChain!,
          launchRedirect: () {
            w3mService.launchConnectedWallet();
          },
        ),
        const SizedBox.square(dimension: 12.0),
      ],
    );
  }
}

final _exampleCustomChain = W3MChainInfo(
  chainName: 'Celo',
  namespace: 'eip155:42220',
  chainId: '42220',
  tokenName: 'CELO',
  optionalNamespaces: {
    'eip155': const RequiredNamespace(
      methods: EthConstants.allMethods,
      chains: ['eip155:42220'],
      events: EthConstants.allEvents,
    ),
  },
  rpcUrl: 'https://1rpc.io/celo',
  blockExplorer: W3MBlockExplorer(
    name: 'Celo Scan',
    url: 'https://celoscan.io',
  ),
);
