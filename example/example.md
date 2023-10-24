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
  late W3MService _w3mService;

  @override
  void initState() {
    super.initState();
    _initializeW3MService();
  }

  void _initializeW3MService() async {
    _w3mService = W3MService(
      projectId: 'YOUR_PROJECT_ID',
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

    await _w3mService.init();
  }

  @override
  void dispose() {
    _w3mService.removeListener(_onWalletUpdated);
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