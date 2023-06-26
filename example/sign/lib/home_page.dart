import 'package:flutter/material.dart';
import 'package:sign/utils/dart_defines.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late IWeb3ModalService _service;
  String? _address;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    _service = Web3ModalService(
      projectId: DartDefines.projectId,
      metadata: const PairingMetadata(
        name: 'Flutter WalletConnect',
        description: 'Flutter Web3Modal Sign Example',
        url: 'https://walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
      ),
      recommendedWalletIds: {
        'afbd95522f4041c71dd4f1a065f971fd32372865b416f95a0b1db759ae33f2a7',
        '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
        // 'c03dfee351b6fcc421b4494ea33b9d4b92a984f87aa76d1663bb28705e95034a',
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
        // '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369' // Defiant
      },
    );
    _address = _service.address;

    _service.addListener(() {
      setState(() {
        _address = _service.address;
      });
    });

    await _service.init();

    setState(() {
      initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Center(
        child: CircularProgressIndicator(
          color: Web3ModalTheme.of(context).data.primary100,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Web3Modal(service: _service),
          Web3ModalConnect(
            web3ModalService: _service,
          ),
          Text(
            'Address: $_address',
            textAlign: TextAlign.center,
          ),
          MaterialButton(
            onPressed:
                _service.isConnected ? _service.launchCurrentWallet : null,
            child: const Text('Launch Current Wallet'),
          ),
        ],
      ),
    );
  }
}
