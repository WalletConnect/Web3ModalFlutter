import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/widgets/debug_drawer.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/utils/constants.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/siwe_service.dart';
import 'package:walletconnect_flutter_dapp/widgets/logger_widget.dart';
import 'package:walletconnect_flutter_dapp/widgets/session_widget.dart';
import 'package:walletconnect_flutter_dapp/utils/dart_defines.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.toggleBrightness,
    required this.toggleTheme,
  });
  final VoidCallback toggleBrightness;
  final VoidCallback toggleTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final overlay = OverlayController(const Duration(milliseconds: 200));
  late W3MService _w3mService;
  late SIWESampleWebService _siweTestService;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _siweTestService = SIWESampleWebService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toggleOverlay();
      SharedPreferences.getInstance().then((instance) {
        _initializeService(instance);
      });
    });
  }

  void _toggleOverlay() {
    overlay.show(context);
  }

  PairingMetadata get _pairingMetadata => const PairingMetadata(
        name: StringConstants.w3mPageTitleV3,
        description: StringConstants.w3mPageTitleV3,
        url: 'https://walletconnect.com/',
        icons: [
          'https://docs.walletconnect.com/assets/images/web3modalLogo-2cee77e07851ba0a710b56d03d4d09dd.png'
        ],
        redirect: Redirect(
          native: 'web3modalflutter://',
          // universal: 'https://walletconnect.com/appkit',
        ),
      );

  SIWEConfig _siweConfig(bool enabled) => SIWEConfig(
        getNonce: () async {
          // this has to be called at the very moment of creating the pairing uri
          try {
            debugPrint('[SIWEConfig] getNonce()');
            final response = await _siweTestService.getNonce();
            return response['nonce'] as String;
          } catch (error) {
            debugPrint('[SIWEConfig] getNonce error: $error');
            // Fallback patch for testing purposes in case SIWE backend has issues
            return AuthSignature.generateNonce();
          }
        },
        getMessageParams: () async {
          // Provide everything that is needed to construct the SIWE message
          debugPrint('[SIWEConfig] getMessageParams()');
          final uri = Uri.parse(_pairingMetadata.url);
          return SIWEMessageArgs(
            domain: uri.authority,
            uri: 'https://${uri.authority}/login',
            statement: 'Welcome to AppKit $packageVersion for Flutter.',
            methods: MethodsConstants.allMethods,
          );
        },
        createMessage: (SIWECreateMessageArgs args) {
          // Create SIWE message to be signed.
          // You can use our provided formatMessage() method of implement your own
          debugPrint('[SIWEConfig] createMessage()');
          return AuthSignature.formatMessage(args);
        },
        verifyMessage: (SIWEVerifyMessageArgs args) async {
          // Implement your verifyMessage to authenticate the user after it.
          try {
            debugPrint('[SIWEConfig] verifyMessage()');
            final payload = args.toJson();
            final uri = Uri.parse(_pairingMetadata.url);
            final result = await _siweTestService.verifyMessage(
              payload,
              domain: uri.authority,
            );
            return result['token'] != null;
          } catch (error) {
            debugPrint('[SIWEConfig] verifyMessage error: $error');
            // Fallback patch for testing purposes in case SIWE backend has issues
            final chainId = AuthSignature.getChainIdFromMessage(args.message);
            final address = AuthSignature.getAddressFromMessage(args.message);
            final cacaoSignature = args.cacao != null
                ? args.cacao!.s
                : CacaoSignature(
                    t: CacaoSignature.EIP191,
                    s: args.signature,
                  );
            return await AuthSignature.verifySignature(
              address,
              args.message,
              cacaoSignature,
              chainId,
              DartDefines.projectId,
            );
          }
        },
        getSession: () async {
          // Return proper session from your Web Service
          try {
            debugPrint('[SIWEConfig] getSession()');
            final session = await _siweTestService.getSession();
            final address = session['address']!.toString();
            final chainId = session['chainId']!.toString();
            return SIWESession(address: address, chains: [chainId]);
          } catch (error) {
            debugPrint('[SIWEConfig] getSession error: $error');
            // Fallback patch for testing purposes in case SIWE backend has issues
            final address = _w3mService.session!.address!;
            final chainId = _w3mService.session!.chainId;
            return SIWESession(address: address, chains: [chainId]);
          }
        },
        onSignIn: (SIWESession session) {
          // Called after SIWE message is signed and verified
          debugPrint('[SIWEConfig] onSignIn()');
        },
        signOut: () async {
          // Called when user taps on disconnect button
          try {
            debugPrint('[SIWEConfig] signOut()');
            final _ = await _siweTestService.signOut();
            return true;
          } catch (error) {
            debugPrint('[SIWEConfig] signOut error: $error');
            // Fallback patch for testing purposes in case SIWE backend has issues
            return true;
          }
        },
        onSignOut: () {
          // Called when disconnecting WalletConnect session was successfull
          debugPrint('[SIWEConfig] onSignOut()');
        },
        enabled: enabled,
        // signOutOnDisconnect: true,
        // signOutOnAccountChange: true,
        // signOutOnNetworkChange: true,
        // nonceRefetchIntervalMs: 300000,
        // sessionRefetchIntervalMs: 300000,
      );

  void _initializeService(SharedPreferences prefs) async {
    final analyticsValue = prefs.getBool('app_w3m_analytics') ?? true;
    final emailWalletValue = prefs.getBool('app_w3m_email_wallet') ?? true;
    final siweAuthValue = prefs.getBool('app_w3m_siwe_auth') ?? true;

    // See https://docs.walletconnect.com/appkit/flutter/core/custom-chains
    W3MChainPresets.chains.addAll(W3MChainPresets.extraChains);
    W3MChainPresets.chains.addAll(W3MChainPresets.testChains);

    try {
      _w3mService = W3MService(
        context: context,
        projectId: DartDefines.projectId,
        logLevel: LogLevel.error,
        metadata: _pairingMetadata,
        siweConfig: _siweConfig(siweAuthValue),
        enableAnalytics: analyticsValue, // OPTIONAL - null by default
        enableEmail: emailWalletValue, // OPTIONAL - false by default
        // requiredNamespaces: {},
        // optionalNamespaces: {},
        // includedWalletIds: {},
        featuredWalletIds: {
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase
          '18450873727504ae9315a084fa7624b5297d2fe5880f0982979c17345a138277', // Kraken Wallet
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // Metamask
          '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369', // Rainbow
          'c03dfee351b6fcc421b4494ea33b9d4b92a984f87aa76d1663bb28705e95034a', // Uniswap
          '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662', // Bitget
        },
        // excludedWalletIds: {
        //   'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase
        // },
        // MORE WALLETS https://explorer.walletconnect.com/?type=wallet&chains=eip155%3A1
      );
      setState(() => _initialized = true);
    } on W3MServiceException catch (e) {
      debugPrint('⛔️ ${e.message}');
      return;
    }
    // modal specific subscriptions
    _w3mService.onModalConnect.subscribe(_onModalConnect);
    _w3mService.onModalUpdate.subscribe(_onModalUpdate);
    _w3mService.onModalNetworkChange.subscribe(_onModalNetworkChange);
    _w3mService.onModalDisconnect.subscribe(_onModalDisconnect);
    _w3mService.onModalError.subscribe(_onModalError);
    // session related subscriptions
    _w3mService.onSessionExpireEvent.subscribe(_onSessionExpired);
    _w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
    // relayClient subscriptions
    _w3mService.web3App!.core.relayClient.onRelayClientConnect.subscribe(
      _onRelayClientConnect,
    );
    _w3mService.web3App!.core.relayClient.onRelayClientError.subscribe(
      _onRelayClientError,
    );
    _w3mService.web3App!.core.relayClient.onRelayClientDisconnect.subscribe(
      _onRelayClientDisconnect,
    );
    //
    await _w3mService.init();
    setState(() {});
  }

  @override
  void dispose() {
    //
    _w3mService.web3App!.core.relayClient.onRelayClientConnect.unsubscribe(
      _onRelayClientConnect,
    );
    _w3mService.web3App!.core.relayClient.onRelayClientError.unsubscribe(
      _onRelayClientError,
    );
    _w3mService.web3App!.core.relayClient.onRelayClientDisconnect.unsubscribe(
      _onRelayClientDisconnect,
    );
    //
    _w3mService.onModalConnect.unsubscribe(_onModalConnect);
    _w3mService.onModalUpdate.unsubscribe(_onModalUpdate);
    _w3mService.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    _w3mService.onModalDisconnect.unsubscribe(_onModalDisconnect);
    _w3mService.onModalError.unsubscribe(_onModalError);
    //
    _w3mService.onSessionExpireEvent.unsubscribe(_onSessionExpired);
    _w3mService.onSessionUpdateEvent.unsubscribe(_onSessionUpdate);
    _w3mService.onSessionEventEvent.unsubscribe(_onSessionEvent);
    //
    super.dispose();
  }

  void _onModalConnect(ModalConnect? event) async {
    setState(() {});
    debugPrint('[ExampleApp] _onModalConnect ${event?.session.toJson()}');
  }

  void _onModalUpdate(ModalConnect? event) {
    setState(() {});
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    debugPrint('[ExampleApp] _onModalNetworkChange ${event?.toString()}');
    setState(() {});
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint('[ExampleApp] _onModalDisconnect ${event?.toString()}');
    setState(() {});
  }

  void _onModalError(ModalError? event) {
    debugPrint('[ExampleApp] _onModalError ${event?.toString()}');
    // When user connected to Coinbase Wallet but Coinbase Wallet does not have a session anymore
    // (for instance if user disconnected the dapp directly within Coinbase Wallet)
    // Then Coinbase Wallet won't emit any event
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      _w3mService.disconnect();
    }
    setState(() {});
  }

  void _onSessionExpired(SessionExpire? event) {
    debugPrint('[ExampleApp] _onSessionExpired ${event?.toString()}');
    setState(() {});
  }

  void _onSessionUpdate(SessionUpdate? event) {
    debugPrint('[ExampleApp] _onSessionUpdate ${event?.toString()}');
    setState(() {});
  }

  void _onSessionEvent(SessionEvent? event) {
    debugPrint('[ExampleApp] _onSessionEvent ${event?.toString()}');
    setState(() {});
  }

  void _onRelayClientConnect(EventArgs? event) {
    setState(() {});
    showTextToast(text: 'Relay connected', context: context);
  }

  void _onRelayClientError(EventArgs? event) {
    setState(() {});
    showTextToast(text: 'Relay disconnected', context: context);
  }

  void _onRelayClientDisconnect(EventArgs? event) {
    setState(() {});
    showTextToast(
      text: 'Relay disconnected: ${event?.toString()}',
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Web3ModalTheme.colorsOf(context).background125,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(StringConstants.w3mPageTitleV3),
        backgroundColor: Web3ModalTheme.colorsOf(context).background175,
        foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
      ),
      body: !_initialized
          ? const SizedBox.shrink()
          : RefreshIndicator(
              onRefresh: () => _refreshData(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox.square(dimension: 4.0),
                    _ButtonsView(w3mService: _w3mService),
                    const Divider(height: 0.0, color: Colors.transparent),
                    _ConnectedView(w3mService: _w3mService),
                  ],
                ),
              ),
            ),
      endDrawer: Drawer(
        backgroundColor: Web3ModalTheme.colorsOf(context).background125,
        child: DebugDrawer(
          toggleOverlay: _toggleOverlay,
          toggleBrightness: widget.toggleBrightness,
          toggleTheme: widget.toggleTheme,
        ),
      ),
      onEndDrawerChanged: (isOpen) {
        // write your callback implementation here
        if (isOpen) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Text(
                'If you made changes you\'ll need to restart the app',
              ),
            );
          },
        );
      },
      floatingActionButton: CircleAvatar(
        radius: 6.0,
        backgroundColor: _initialized &&
                _w3mService.web3App?.core.relayClient.isConnected == true
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  Future<void> _refreshData() async {
    await _w3mService.reconnectRelay();
    await _w3mService.loadAccountData();
    setState(() {});
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
          child: W3MNetworkSelectButton(
            service: w3mService,
            context: context,
            // UNCOMMENT TO USE A CUSTOM BUTTON
            // custom: ElevatedButton(
            //   style: buttonStyle(context),
            //   onPressed: () {
            //     w3mService.openNetworksView();
            //   },
            //   child: const Text('OPEN CHAINS'),
            // ),
          ),
        ),
        W3MConnectWalletButton(
          service: w3mService,
          context: context,
          // UNCOMMENT TO USE A CUSTOM BUTTON
          // TO HIDE W3MConnectWalletButton BUT STILL RENDER IT (NEEDED) JUST USE SizedBox.shrink()
          // custom: ElevatedButton(
          //   style: buttonStyle(context),
          //   onPressed: () {
          //     w3mService.openModalView();
          //   },
          //   child: w3mService.isConnected
          //       ? Text(Util.truncate(w3mService.session!.address!))
          //       : const Text('CONNECT WALLET'),
          // ),
        ),
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
        ValueListenableBuilder<String>(
          valueListenable: w3mService.balanceNotifier,
          builder: (_, balance, __) {
            return W3MAccountButton(
              service: w3mService,
              context: context,
              // UNCOMMENT TO USE A CUSTOM BUTTON
              // custom: ElevatedButton(
              //   style: buttonStyle(context),
              //   onPressed: () {
              //     w3mService.openModalView();
              //   },
              //   child: Text(balance),
              // ),
            );
          },
        ),
        SessionWidget(w3mService: w3mService),
        const SizedBox.square(dimension: 12.0),
      ],
    );
  }
}
