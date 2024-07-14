```dart
///
/// For a more complete example please refer to the /example folder
///
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
  late W3MService _w3mService;

  @override
  void initState() {
    super.initState();
    _initializeW3MService();
  }

  void _initializeW3MService() async {
    // Add your own custom chain to chains presets list to show when using W3MNetworkSelectButton
    // See https://docs.walletconnect.com/appkit/flutter/core/custom-chains
    // W3MChainPresets.chains.putIfAbsent('<chainID>', () => <Your W3MChainInfo>);

    _w3mService = W3MService(
      projectId: 'YOUR_PROJECT_ID',
      metadata: const PairingMetadata(
        name: 'AppKit Flutter Example',
        description: 'AppKit Flutter Example',
        url: 'https://walletconnect.com/',
        icons: [
          'https://docs.walletconnect.com/assets/images/web3modalLogo-2cee77e07851ba0a710b56d03d4d09dd.png'
        ],
        redirect: Redirect(
          native: 'web3modalflutter://',
          universal: 'https://walletconnect.com/appkit',
        ),
      ),
    );

    await _w3mService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Web3ModalTheme(
      isDarkMode: true,
      child: MaterialApp(
        title: 'AppKit Demo',
        home: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('AppKit Demo'),
                backgroundColor: Web3ModalTheme.colorsOf(context).background100,
                foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
              ),
              backgroundColor: Web3ModalTheme.colorsOf(context).background300,
              body: Container(
                constraints: const BoxConstraints.expand(),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: !_w3mService.isConnected
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