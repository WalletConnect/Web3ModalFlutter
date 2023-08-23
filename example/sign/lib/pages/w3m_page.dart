import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sign/utils/constants.dart';
import 'package:sign/utils/string_constants.dart';
import 'package:sign/widgets/session_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class W3MPage extends StatefulWidget {
  const W3MPage({
    super.key,
    required this.web3App,
  });

  final IWeb3App web3App;

  @override
  State<W3MPage> createState() => _W3MPageState();
}

class _W3MPageState extends State<W3MPage> with SingleTickerProviderStateMixin {
  bool _initialized = false;

  IW3MService? _w3mService;

  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    _w3mService = W3MService(
      web3App: widget.web3App,
      recommendedWalletIds: {
        'afbd95522f4041c71dd4f1a065f971fd32372865b416f95a0b1db759ae33f2a7',
        '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
      },
    );

    widget.web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    widget.web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);

    await _w3mService?.init();

    _isConnected = widget.web3App.sessions.getAll().isNotEmpty;

    setState(() {
      _initialized = true;
    });
  }

  @override
  void dispose() {
    widget.web3App.onSessionConnect.unsubscribe(_onWeb3AppConnect);
    widget.web3App.onSessionDelete.unsubscribe(_onWeb3AppDisconnect);
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
    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          color: WalletConnectModalTheme.getData(context).primary100,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: _isConnected ? _buildConnected() : _buildConnect(),
    );
  }

  Widget _buildConnected() {
    final SessionData session = widget.web3App.sessions.getAll().first;

    // Assign the button based on the type
    Widget button = W3MConnect(
      service: _w3mService!,
      buttonRadius: 20,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Web3Modal',
          style: StyleConstants.titleText,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: SessionWidget(
                session: session,
                web3App: widget.web3App,
                launchRedirect: () {
                  _w3mService!.launchCurrentWallet();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnect() {
    return _buildWeb3Modal();
  }

  Widget _buildWeb3Modal() {
    return ListView(
      children: [
        const Text(
          StringConstants.selectChains,
          style: StyleConstants.subtitleText,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: StyleConstants.linear24,
        ),
        W3MConnect(
          service: _w3mService!,
          buttonRadius: 20,
        ),
        const SizedBox(
          height: StyleConstants.linear8,
        ),
        W3MNetworkSelect(
          service: _w3mService!,
          buttonRadius: 20,
        ),
      ],
    );
  }
}
