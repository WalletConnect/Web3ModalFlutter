import 'package:flutter/material.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/widgets/session_widget.dart';
import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/chain_data_wrapper.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/helpers.dart';
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

    // Loop through all the chain data
    for (final ChainMetadata chain in ChainDataWrapper.chains) {
      // Loop through the events for that chain
      for (final event in getChainEvents(chain.type)) {
        _web3App!.registerEventHandler(
          chainId: chain.w3mChainInfo.namespace,
          event: event,
          handler: null,
        );
      }
    }

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
    _w3mService = W3MService(
      web3App: _web3App,
      logLevel: LogLevel.error,
      // featuredWalletIds: {
      //   'f2436c67184f158d1beda5df53298ee84abfc367581e4505134b5bcf5f46697d',
      //   '8a0ee50d1f22f6651afcae7eb4253e52a3310b90af5daef78a8c4929a9bb99d4',
      //   'f5b4eeb6015d66be3f5940a895cbaa49ef3439e518cd771270e6b553b48f31d2',
      // },
    );

    // See https://docs.walletconnect.com/web3modal/flutter/custom-chains
    W3MChainPresets.chains.putIfAbsent('42220', () => myCustomChain);
    W3MChainPresets.chains.putIfAbsent('11155111', () => sepoliaTestnet);
    await _w3mService.init();
    // _w3mService.selectChain(myCustomChain);

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
    // If we connect, default to barebones
    setState(() {
      _isConnected = true;
    });
  }

  void _onWeb3AppDisconnect(SessionDelete? args) {
    setState(() {
      _isConnected = false;
    });
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
          W3MConnectWalletButton(
            service: _w3mService,
            state: ConnectButtonState.none,
          ),
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

  W3MChainInfo get myCustomChain => W3MChainInfo(
        chainName: 'Celo',
        namespace: 'eip155:42220',
        chainId: '42220',
        tokenName: 'CELO',
        requiredNamespaces: {
          'eip155': const RequiredNamespace(
            methods: [
              'personal_sign',
              'eth_signTypedData',
              'eth_sendTransaction',
            ],
            chains: ['eip155:42220'],
            events: [
              'chainChanged',
              'accountsChanged',
            ],
          ),
        },
        optionalNamespaces: {
          'eip155': const RequiredNamespace(
            methods: [
              'wallet_switchEthereumChain',
              'wallet_addEthereumChain',
            ],
            chains: ['eip155:42220'],
            events: [],
          ),
        },
        rpcUrl: 'https://1rpc.io/celo',
        blockExplorer: W3MBlockExplorer(
          name: 'Celo Scan',
          url: 'https://celoscan.io',
        ),
      );

  W3MChainInfo sepoliaTestnet = W3MChainInfo(
    chainName: 'Sepolia Test Network',
    namespace: 'eip155:11155111',
    chainId: '11155111',
    tokenName: 'SETH',
    chainIcon:
        'https://assets-global.website-files.com/5f973c97cf5aea614f93a26c/6495cd7e2f11ba72bd274ef6_alchemy-rpc-node-provider-logo.png',
    requiredNamespaces: {
      'eip155': const RequiredNamespace(
        methods: EthConstants.ethRequiredMethods,
        chains: ['eip155:11155111'],
        events: EthConstants.ethEvents,
      ),
    },
    optionalNamespaces: {
      'eip155': const RequiredNamespace(
        methods: EthConstants.ethOptionalMethods,
        chains: ['eip155:11155111'],
        events: [],
      ),
    },
    rpcUrl: 'https://rpc.sepolia.org',
    blockExplorer: W3MBlockExplorer(
      name: 'Sepolia Etherscan',
      url: 'https://sepolia.etherscan.io',
    ),
  );
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
          launchRedirect: () {
            w3mService.launchConnectedWallet();
          },
        ),
        const SizedBox.square(dimension: 12.0),
      ],
    );
  }
}
