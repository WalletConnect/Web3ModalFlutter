import 'package:flutter/material.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/widgets/session_widget.dart';
import 'package:walletconnect_flutter_dapp/utils/dart_defines.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.swapTheme,
    required this.changeTheme,
  });
  final VoidCallback swapTheme;
  final VoidCallback changeTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late W3MService _w3mService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    // See https://docs.walletconnect.com/web3modal/flutter/custom-chains
    W3MChainPresets.chains.putIfAbsent(_celo.chainId, () => _celo);
    W3MChainPresets.chains.putIfAbsent(_sepolia.chainId, () => _sepolia);

    _w3mService = W3MService(
      projectId: DartDefines.projectId,
      logLevel: LogLevel.error,
      metadata: const PairingMetadata(
        name: StringConstants.w3mPageTitleV3,
        description: StringConstants.w3mPageTitleV3,
        url: 'https://web3modal.com/',
        icons: [
          'https://docs.walletconnect.com/assets/images/web3modalLogo-2cee77e07851ba0a710b56d03d4d09dd.png'
        ],
        redirect: Redirect(
          native: 'web3modalflutter://',
          universal: 'https://web3modal.com',
        ),
      ),
      // excludedWalletIds: {
      //   'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase Wallet
      // },
      // includedWalletIds: {
      //   'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // Metamask
      //   '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369', // Rainbow
      //   'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase Wallet
      //   'be49f0a78d6ea1beed3804c3a6b62ea71f568d58d9df8097f3d61c7c9baf273d', // Uniswap
      // },
      // featuredWalletIds: {
      //   '19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927', // Ledger Live
      //   '4457c130df49fb3cb1f8b99574b97b35208bd3d0d13b8d25d2b5884ed2cad13a', // Shapeshift
      //   'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase Wallet
      //   '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662', // Bitget
      // },
    );

    // If you want to support just one chain uncomment this line and avoid using W3MNetworkSelectButton()
    // _w3mService.selectChain(W3MChainPresets.chains['137']);

    _w3mService.addListener(_serviceListener);
    //
    _w3mService.onModalConnect.subscribe(_onModalConnect);
    _w3mService.onModalDisconnect.subscribe(_onModalDisconnect);
    _w3mService.onModalError.subscribe(_onModalError);
    //
    // _w3mService.onSessionConnectEvent.subscribe(_onSessionConnect);
    // _w3mService.onSessionDeleteEvent.subscribe(_onSessionDelete);
    _w3mService.onSessionExpireEvent.subscribe(_onSessionExpired);
    _w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
    //
    // _w3mService.onCoinbaseConnect.subscribe((args) {});
    // _w3mService.onCoinbaseError.subscribe((args) {});
    // _w3mService.onCoinbaseSessionUpdate.subscribe((args) {});
    //
    await _w3mService.init();
  }

  @override
  void dispose() {
    _w3mService.removeListener(_serviceListener);
    //
    _w3mService.onModalConnect.unsubscribe(_onModalConnect);
    _w3mService.onModalDisconnect.unsubscribe(_onModalDisconnect);
    _w3mService.onModalError.unsubscribe(_onModalError);
    //
    // _w3mService.onSessionConnectEvent.unsubscribe(_onSessionConnect);
    // _w3mService.onSessionDeleteEvent.unsubscribe(_onSessionDelete);
    _w3mService.onSessionExpireEvent.unsubscribe(_onSessionExpired);
    _w3mService.onSessionUpdateEvent.unsubscribe(_onSessionUpdate);
    _w3mService.onSessionEventEvent.unsubscribe(_onSessionEvent);
    //
    // _w3mService.onCoinbaseConnect.unsubscribe((args) {});
    // _w3mService.onCoinbaseError.unsubscribe((args) {});
    // _w3mService.onCoinbaseSessionUpdate.unsubscribe((args) {});
    super.dispose();
  }

  void _serviceListener() {
    setState(() {});
  }

  void _onModalConnect(ModalConnect? event) {
    debugPrint('[$runtimeType] modal connect ${event?.toString()}');
    debugPrint('[$runtimeType] modal connect ${event?.session.address}');
    debugPrint('[$runtimeType] modal connect ${_w3mService.session?.address}');
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint('[$runtimeType] modal disconnect ${event?.toString()}');
  }

  void _onModalError(ModalError? event) {
    debugPrint('[$runtimeType] _onModalError ${event?.toString()}');
    // When user connected to Coinbase Wallet but Coinbase Wallet does not have a session anymore
    // (for instance if user disconnected the dapp directly within Coinbase Wallet)
    // Then Coinbase Wallet won't emit any event
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      _w3mService.disconnect();
    }
  }

  void _onSessionExpired(SessionExpire? event) {
    debugPrint('[$runtimeType] _onSessionExpired ${event?.toString()}');
  }

  void _onSessionUpdate(SessionUpdate? event) {
    debugPrint('[$runtimeType] _onSessionUpdate ${event?.toString()}');
  }

  void _onSessionEvent(SessionEvent? event) {
    debugPrint('[$runtimeType] _onSessionEvent ${event?.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = Web3ModalTheme.isCustomTheme(context);
    return Scaffold(
      backgroundColor: Web3ModalTheme.colorsOf(context).background125,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(StringConstants.w3mPageTitleV3),
        backgroundColor: Web3ModalTheme.colorsOf(context).background175,
        foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
        actions: [
          IconButton(
            icon: isCustom
                ? const Icon(Icons.yard)
                : const Icon(Icons.yard_outlined),
            onPressed: widget.changeTheme,
          ),
          IconButton(
            icon: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false
                ? const Icon(Icons.light_mode_outlined)
                : const Icon(Icons.dark_mode_outlined),
            onPressed: widget.swapTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox.square(dimension: 4.0),
            Text(
              'Custom theme is: ${isCustom ? 'ON' : 'OFF'}',
              style: TextStyle(
                color: Web3ModalTheme.colorsOf(context).foreground100,
              ),
            ),
            _ButtonsView(w3mService: _w3mService),
            const Divider(height: 0.0, color: Colors.transparent),
            _ConnectedView(w3mService: _w3mService)
          ],
        ),
      ),
    );
  }
}

class _ButtonsView extends StatelessWidget {
  const _ButtonsView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox.square(dimension: 8.0),
        Visibility(
          visible: !w3mService.isConnected,
          child: W3MNetworkSelectButton(service: w3mService),
        ),
        W3MConnectWalletButton(service: w3mService),
        const SizedBox.square(dimension: 8.0),
      ],
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    if (!w3mService.isConnected) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(dimension: 12.0),
        W3MAccountButton(service: w3mService),
        SessionWidget(
          w3mService: w3mService,
          launchRedirect: () {
            w3mService.launchConnectedWallet();
          },
        ),
        const SizedBox.square(dimension: 12.0),
      ],
    );
  }
}

final _celo = W3MChainInfo(
  chainName: 'Celo',
  namespace: 'eip155:42220',
  chainId: '42220',
  tokenName: 'CELO',
  rpcUrl: 'https://forno.celo.org/',
  blockExplorer: W3MBlockExplorer(
    name: 'Celo Explorer',
    url: 'https://explorer.celo.org/mainnet',
  ),
);

final _sepolia = W3MChainInfo(
  chainName: 'Sepolia Testnet',
  chainId: '11155111',
  namespace: 'eip155:11155111',
  tokenName: 'ETH',
  rpcUrl: 'https://ethereum-sepolia.publicnode.com',
  blockExplorer: W3MBlockExplorer(
    name: 'Sepolia Etherscan',
    url: 'https://sepolia.etherscan.io/',
  ),
);
