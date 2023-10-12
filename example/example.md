```dart
import 'package:flutter/material.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late IWeb3App _web3App;
  late W3MService _w3mService;

  bool _initialized = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeWeb3App();
  }

  void _initializeWeb3App() async {
    _web3App = Web3App(
      core: Core(projectId: '{YOUR_PROJECT_ID}'),
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );

    _web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);

    await _web3App.init();

    _initializeW3MService();
  }

  void _initializeW3MService() async {
    _w3mService = W3MService(
      web3App: _web3App,
      featuredWalletIds: {
        'afbd95522f4041c71dd4f1a065f971fd32372865b416f95a0b1db759ae33f2a7',
        '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
      },
    );

    await _w3mService.init();

    setState(() => _initialized = true);
  }

  void _onWeb3AppConnect(SessionConnect? args) => setState(() {
        _isConnected = true;
      });

  void _onWeb3AppDisconnect(SessionDelete? args) => setState(() {
        _isConnected = false;
      });

  @override
  void dispose() {
    _web3App.onSessionConnect.unsubscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.unsubscribe(_onWeb3AppDisconnect);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Web3ModalTheme(
      isDarkMode: true,
      child: MaterialApp(
        title: 'Web3Modal Demo',
        home: Builder(
          builder: (context) {
            if (!_initialized) {
              return Center(
                child: CircularProgressIndicator(
                  color: Web3ModalTheme.colorsOf(context).accent100,
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Web3Modal Demo'),
                backgroundColor: Web3ModalTheme.colorsOf(context).background100,
                foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
              ),
              backgroundColor: Web3ModalTheme.colorsOf(context).background300,
              body: Container(
                constraints: const BoxConstraints.expand(),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: !_isConnected
                      ? [
                          W3MNetworkSelectButton(service: _w3mService),
                          W3MConnectWalletButton(service: _w3mService),
                        ]
                      : [
                          W3MAccountButton(service: _w3mService),
                        ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

```