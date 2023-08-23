import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sign/models/chain_metadata.dart';
import 'package:sign/utils/constants.dart';
import 'package:sign/utils/crypto/chain_data_wrapper.dart';
import 'package:sign/utils/crypto/helpers.dart';
import 'package:sign/utils/string_constants.dart';
import 'package:sign/widgets/chain_button.dart';
import 'package:sign/widgets/session_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';

class WCMPage extends StatefulWidget {
  const WCMPage({
    super.key,
    required this.web3App,
  });

  final IWeb3App web3App;

  @override
  State<WCMPage> createState() => _WCMPageState();
}

class _WCMPageState extends State<WCMPage> with SingleTickerProviderStateMixin {
  bool _initialized = false;

  IWalletConnectModalService? _walletConnectModalService;

  bool _testnetOnly = false;
  final List<ChainMetadata> _selectedChains = [];

  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    _walletConnectModalService = WalletConnectModalService(
      web3App: widget.web3App,
      recommendedWalletIds: {
        'afbd95522f4041c71dd4f1a065f971fd32372865b416f95a0b1db759ae33f2a7',
        '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
      },
    );

    widget.web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    widget.web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);

    await _walletConnectModalService?.init();

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

    if (_isConnected) {
      return _buildConnected();
    } else {
      return _buildConnect();
    }
  }

  Widget _buildConnected() {
    final SessionData session = widget.web3App.sessions.getAll().first;

    // Assign the button based on the type
    Widget button = WalletConnectModalConnect(
      service: _walletConnectModalService!,
      buttonRadius: 20,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WalletConnect Modal',
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
                  _walletConnectModalService!.launchCurrentWallet();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnect() {
    return _buildWalletConnect();
  }

  Widget _buildWalletConnect() {
    // Build the list of chain button
    final List<ChainMetadata> chains = ChainDataWrapper.chains;

    List<Widget> chainButtons = [];

    for (final ChainMetadata chain in chains) {
      // Build the button
      chainButtons.add(
        ChainButton(
          chain: chain,
          onPressed: () {
            _selectChain(
              chain,
              // deselectOthers: true,
            );
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
        WalletConnectModalConnect(
          service: _walletConnectModalService!,
          buttonRadius: 20,
        ),
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
    _updateRequiredNamespaces();
  }

  void _updateRequiredNamespaces() {
    final Map<String, RequiredNamespace> requiredNamespaces =
        _getRequiredNamespaces();
    LoggerUtil.logger
        .i('_updateRequiredNamespaces, namespaces: $requiredNamespaces');
    _walletConnectModalService?.setOptionalNamespaces(
      optionalNamespaces: requiredNamespaces,
    );
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
      requiredNamespaces[entry.key.name] = RequiredNamespace(
        chains: entry.value.toList(),
        methods: getChainMethods(entry.key),
        events: getChainEvents(entry.key),
      );
    }

    LoggerUtil.logger
        .i('WCM Page, _getRequiredNamespaces: $requiredNamespaces');
    return requiredNamespaces;
  }
}
