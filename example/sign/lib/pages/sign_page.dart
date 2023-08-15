import 'dart:async';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sign/models/chain_metadata.dart';
import 'package:sign/utils/constants.dart';
import 'package:sign/utils/crypto/chain_data.dart';
import 'package:sign/utils/crypto/helpers.dart';
import 'package:sign/utils/string_constants.dart';
import 'package:sign/widgets/chain_button.dart';
import 'package:sign/widgets/session_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/services/w3m_service/w3m_service.dart';
import 'package:web3modal_flutter/widgets/w3m_connect.dart';
import 'package:web3modal_flutter/widgets/w3m_network_select.dart';

class SignPage extends StatefulWidget {
  const SignPage({
    super.key,
    required this.web3App,
  });

  final IWeb3App web3App;

  @override
  SignPageState createState() => SignPageState();
}

class SignPageState extends State<SignPage>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  IWalletConnectModalService? _walletConnectModalService;
  IW3MService? _w3mService;

  bool _testnetOnly = false;
  final List<ChainMetadata> _selectedChains = [];

  bool _shouldDismissQrCode = true;

  bool _isConnected = false;

  static const List<Tab> options = [
    Tab(text: 'Bare Bones'),
    Tab(text: 'WalletConnect Modal'),
    Tab(text: 'Web3Modal'),
  ];
  late TabController _tabController;
  // late PageController _pageController;

  @override
  void initState() {
    super.initState();

    // _pageController = PageController();
    _tabController = TabController(
      vsync: this,
      length: options.length,
    );
    _tabController.addListener(_tabChanged);

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
    _w3mService = W3MService(
      web3App: widget.web3App,
      recommendedWalletIds: {
        'afbd95522f4041c71dd4f1a065f971fd32372865b416f95a0b1db759ae33f2a7',
        '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662',
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
      },
    );
    _isConnected = _walletConnectModalService!.isConnected;

    _walletConnectModalService?.addListener(_modalListener);
    _w3mService?.addListener(_modalListener);

    await _walletConnectModalService?.init();
    await _w3mService?.init();

    // Loop through all the chain data
    for (final ChainMetadata chain in ChainData.allChains) {
      // Loop through the events for that chain
      for (final event in getChainEvents(chain.type)) {
        widget.web3App.registerEventHandler(
          chainId: chain.chainId,
          event: event,
          handler: null,
        );
      }
    }

    setState(() {
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabChanged);
    _walletConnectModalService?.removeListener(_modalListener);
    _w3mService?.removeListener(_modalListener);
    super.dispose();
  }

  void _modalListener() {
    setState(() {
      _isConnected =
          _walletConnectModalService!.isConnected || _w3mService!.isConnected;
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

    // return Center(
    //   child: W3MConnect(
    //     service: _w3mService!,
    //     buttonRadius: 20,
    //   ),
    // );

    // return Container(
    //   padding: const EdgeInsets.all(8.0),
    //   child: SessionWidget(
    //     session: session,
    //     web3App: widget.web3App,
    //     launchRedirect: () {
    //       _walletConnectModalService!.launchCurrentWallet();
    //     },
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Connected",
          style: StyleConstants.titleText,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          WalletConnectModalConnect(
            service: _walletConnectModalService!,
            buttonRadius: 20,
          ),
          W3MConnect(
            service: _w3mService!,
            buttonRadius: 20,
          ),
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
    List<Widget> pages = [
      Container(
        padding: const EdgeInsets.all(8.0),
        child: _buildBareBones(),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: _buildWalletConnect(),
      ),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: _buildWeb3Modal(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: options,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: pages,
      ),
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

  Widget _buildBareBones() {
    // Build the list of chain button
    final List<ChainMetadata> chains =
        _testnetOnly ? ChainData.testChains : ChainData.mainChains;

    List<Widget> chainButtons = [];

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
        _buildTestnetSwitch(),
        ...chainButtons,
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
      ],
    );
  }

  Widget _buildWalletConnect() {
    // Build the list of chain button
    final List<ChainMetadata> chains =
        _testnetOnly ? ChainData.testChains : ChainData.mainChains;

    List<Widget> chainButtons = [];

    for (final ChainMetadata chain in chains) {
      // Build the button
      chainButtons.add(
        ChainButton(
          chain: chain,
          onPressed: () {
            _selectChain(
              chain,
              deselectOthers: true,
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
        _buildTestnetSwitch(),
        ...chainButtons,
        WalletConnectModalConnect(
          service: _walletConnectModalService!,
          buttonRadius: 20,
        ),
      ],
    );
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
        _buildTestnetSwitch(),
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

  void _tabChanged() {
    setState(() {
      _selectedChains.clear();
    });
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

  Map<String, RequiredNamespace> _getRequiredNamespaces() {
    final Map<String, RequiredNamespace> requiredNamespaces = {};
    for (final chain in _selectedChains) {
      // If the chain is already in the required namespaces, add it to the chains list
      final String chainName = chain.chainId.split(':')[0];
      if (requiredNamespaces.containsKey(chainName)) {
        requiredNamespaces[chainName]!.chains!.add(chain.chainId);
        continue;
      }
      final RequiredNamespace rNamespace = RequiredNamespace(
        chains: [chain.chainId],
        methods: getChainMethods(chain.type),
        events: getChainEvents(chain.type),
      );
      requiredNamespaces[chainName] = rNamespace;
    }

    LoggerUtil.logger.i(requiredNamespaces);
    return requiredNamespaces;
  }

  void _updateRequiredNamespaces() {
    final Map<String, RequiredNamespace> requiredNamespaces =
        _getRequiredNamespaces();
    LoggerUtil.logger
        .i('Updated Required Namespaces, namespaces: $requiredNamespaces');
    LoggerUtil.logger
        .i('Updated Required Namespaces, service: $_walletConnectModalService');
    _walletConnectModalService?.setDefaultChain(
      requiredNamespaces: requiredNamespaces,
    );
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
