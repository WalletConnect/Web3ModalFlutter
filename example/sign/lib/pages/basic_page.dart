import 'dart:async';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:walletconnect_flutter_dapp/utils/constants.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/chain_data_wrapper.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/helpers.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';
import 'package:walletconnect_flutter_dapp/widgets/chain_button.dart';
import 'package:walletconnect_flutter_dapp/widgets/session_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';

enum SignPageType {
  none,
  bareBones,
  walletConnectModal,
  web3Modal,
}

class BasicPage extends StatefulWidget {
  const BasicPage({
    super.key,
    required this.web3App,
  });

  final IWeb3App web3App;

  @override
  State<BasicPage> createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;

  bool _testnetOnly = false;
  final List<ChainMetadata> _selectedChains = [];

  bool _shouldDismissQrCode = true;

  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    widget.web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    widget.web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);

    await widget.web3App.init();

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
    // if (_isConnected) {
    //   return _buildConnected();
    // } else {
    //   return _buildConnect();
    // }
  }

  Widget _buildConnected() {
    final SessionData session = widget.web3App.sessions.getAll().first;

    // Assign the button based on the type
    Widget button = Container(
      width: double.infinity,
      height: StyleConstants.linear48,
      margin: const EdgeInsets.symmetric(
        vertical: StyleConstants.linear8,
      ),
      child: ElevatedButton(
        onPressed: () async {
          await widget.web3App.disconnectSession(
              topic: session.topic,
              reason: Errors.getSdkError(
                Errors.USER_DISCONNECTED,
              ));
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.red,
          ),
        ),
        child: const Text(
          StringConstants.delete,
          style: StyleConstants.buttonText,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Basic',
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
                launchRedirect: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnect() {
    return _buildBareBones();
  }

  Widget _buildBareBones() {
    // Build the list of chain button
    final List<ChainMetadata> chains = ChainDataWrapper.chains;

    List<Widget> chainButtons = [
      Container(
        width: double.infinity,
        height: StyleConstants.linear48,
        margin: const EdgeInsets.symmetric(
          vertical: StyleConstants.linear8,
        ),
        child: ElevatedButton(
          onPressed: () => _onConnect(),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              StyleConstants.primaryColor,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  StyleConstants.linear8,
                ),
              ),
            ),
          ),
          child: const Text(
            StringConstants.bareBonesSign,
            style: StyleConstants.buttonText,
          ),
        ),
      ),
    ];

    for (final ChainMetadata chain in chains) {
      // Build the button
      chainButtons.add(
        ChainButton(
          chain: chain,
          onPressed: () {
            _selectChain(chain);
          },
          selected: _selectedChains.contains(chain),
        ),
      );
    }

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
        // _buildTestnetSwitch(),
        ...chainButtons,
      ],
    );
  }

  Widget _buildTestnetSwitch() {
    return SizedBox(
      height: StyleConstants.linear48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            StringConstants.testnetsOnly,
            style: StyleConstants.buttonText,
          ),
          Switch(
            value: _testnetOnly,
            onChanged: (value) {
              setState(() {
                _testnetOnly = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _selectChain(
    ChainMetadata chain, {
    bool deselectOthers = false,
  }) {
    setState(() {
      if (deselectOthers) {
        _selectedChains.clear();
        _selectedChains.add(chain);
      } else {
        if (_selectedChains.contains(chain)) {
          _selectedChains.remove(chain);
        } else {
          _selectedChains.add(chain);
        }
      }
    });
  }

  Map<String, RequiredNamespace> _getRequiredNamespaces() {
    final Map<String, RequiredNamespace> requiredNamespaces = {};
    final Map<ChainType, Set<String>> chains = {};

    // Construct our list of chains for each type of blockchain
    for (final chain in _selectedChains) {
      if (!chains.containsKey(chain.type)) {
        chains[chain.type] = {};
      }
      chains[chain.type]!.add(chain.w3mChainInfo.namespace);
    }

    for (final entry in chains.entries) {
      // Create the required namespaces
      requiredNamespaces[entry.key.toString()] = RequiredNamespace(
        chains: entry.value.toList(),
        methods: getChainMethods(entry.key),
        events: getChainEvents(entry.key),
      );
    }

    LoggerUtil.logger
        .i('BasicPage _getRequiredNamespaces: $requiredNamespaces');
    return requiredNamespaces;
  }

  Future<void> _onConnect() async {
    // Use the chain metadata to build the required namespaces:
    // Get the methods, get the events
    final Map<String, RequiredNamespace> requiredNamespaces =
        _getRequiredNamespaces();

    // Send off a connect
    debugPrint('Creating connection and session');
    final ConnectResponse res = await widget.web3App.connect(
      requiredNamespaces: requiredNamespaces,
    );
    // debugPrint('Connection created, connection response: ${res.uri}');

    // print(res.uri!.toString());
    _showQrCode(res);

    debugPrint('Awaiting session proposal settlement');
    res.session.future.then(
      (value) {
        showPlatformToast(
          child: const Text(
            StringConstants.connectionEstablished,
          ),
          context: context,
        );

        if (_shouldDismissQrCode) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
    ).catchError((e) {
      showPlatformToast(
        child: const Text(
          StringConstants.connectionFailed,
        ),
        context: context,
      );

      if (_shouldDismissQrCode) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    });
  }

  Future<void> _showQrCode(
    ConnectResponse response,
  ) async {
    // Show the QR code
    debugPrint('Showing QR Code: ${response.uri}');

    _shouldDismissQrCode = true;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            StringConstants.scanQrCode,
            style: StyleConstants.titleText,
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 300,
            height: 350,
            child: Center(
              child: Column(
                children: [
                  QrImageView(
                    data: response.uri!.toString(),
                  ),
                  const SizedBox(
                    height: StyleConstants.linear16,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Clipboard.setData(
                        ClipboardData(
                          text: response.uri!.toString(),
                        ),
                      );
                      await showPlatformToast(
                        child: const Text(
                          StringConstants.copiedToClipboard,
                        ),
                        context: context,
                      );
                    },
                    child: const Text(
                      'Copy URL to Clipboard',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    _shouldDismissQrCode = false;
  }
}
