import 'dart:async';

import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/buttons/address_button.dart';
import 'package:web3modal_flutter/widgets/buttons/balance_button.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/buttons/connect_button.dart';
import 'package:web3modal_flutter/widgets/buttons/network_button.dart';
import 'package:web3modal_flutter/widgets/w3m_account_button.dart';

// import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';

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
  late W3MService _w3mService;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    widget.web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    widget.web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);
    _initializeService();
  }

  Future<bool> _initializeService() async {
    try {
      _w3mService = W3MService(
        web3App: widget.web3App,
        recommendedWalletIds: {
          'afbd95522f4041c71dd4f1a065f971fd32372865b416f95a0b1db759ae33f2a7',
          '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
        },
      );

      await _w3mService.init();
      _isConnected = widget.web3App.sessions.getAll().isNotEmpty;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
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
    return FutureBuilder(
      future: _initializeService(),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == false) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Web3ModalTheme.getDataOf(context).colors.blue100,
            ),
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox.square(dimension: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                W3MNetworkSelectButton(service: _w3mService),
                const SizedBox.square(dimension: 12.0),
                W3MNetworkSelectButton(
                  service: _w3mService,
                  size: BaseButtonSize.small,
                ),
              ],
            ),
            const SizedBox.square(dimension: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                W3MConnectWalletButton(
                  service: _w3mService,
                  state: ConnectButtonState.none,
                ),
                const SizedBox.square(dimension: 12.0),
                W3MConnectWalletButton(
                  service: _w3mService,
                  size: BaseButtonSize.small,
                  state: ConnectButtonState.none,
                ),
              ],
            ),
            const SizedBox.square(dimension: 12.0),
            const Divider(height: 0.0),
            if (_isConnected)
              _ConnectedView(
                w3mService: _w3mService,
              )
          ],
        );
      },
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(dimension: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AddressButton(service: w3mService, onTap: () {}),
              const SizedBox.square(dimension: 12.0),
              AddressButton(service: w3mService),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AddressButton(
                service: w3mService,
                size: BaseButtonSize.small,
                onTap: () {},
              ),
              const SizedBox.square(dimension: 12.0),
              AddressButton(
                service: w3mService,
                size: BaseButtonSize.small,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NetworkButton(service: w3mService, onTap: () {}),
              const SizedBox.square(dimension: 12.0),
              NetworkButton(service: w3mService),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NetworkButton(
                service: w3mService,
                size: BaseButtonSize.small,
                onTap: () {},
              ),
              const SizedBox.square(dimension: 12.0),
              NetworkButton(
                service: w3mService,
                size: BaseButtonSize.small,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BalanceButton(service: w3mService, onTap: () {}),
              const SizedBox.square(dimension: 12.0),
              BalanceButton(service: w3mService),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BalanceButton(
                service: w3mService,
                size: BaseButtonSize.small,
                onTap: () {},
              ),
              const SizedBox.square(dimension: 12.0),
              BalanceButton(
                service: w3mService,
                size: BaseButtonSize.small,
              ),
            ],
          ),
          W3MAccountButton(service: w3mService),
          W3MAccountButton(
            service: w3mService,
            size: BaseButtonSize.small,
          ),
          // Container(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SessionWidget(
          //     session: widget.web3App.sessions.getAll().first,
          //     web3App: widget.web3App,
          //     launchRedirect: () {
          //       _w3mService.launchCurrentWallet();
          //     },
          //   ),
          // ),
          const SizedBox.square(dimension: 12.0),
        ],
      ),
    );
  }
}
