import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/services/explorer/i_explorer_service.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils_singleton.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/chain_data.dart';
import 'package:web3modal_flutter/utils/eth_util.dart';

class W3MService extends WalletConnectModalService implements IW3MService {
  static const String selectedChainId = 'selectedChainId';

  W3MChainInfo? _selectedChain;
  @override
  W3MChainInfo? get selectedChain => _selectedChain;

  String? _tokenImageUrl;
  @override
  String? get tokenImageUrl => _tokenImageUrl;

  String? _avatarUrl;
  @override
  String? get avatarUrl => _avatarUrl;

  double? _chainBalance;
  @override
  double? get chainBalance => _chainBalance;

  W3MService({
    IWeb3App? web3App,
    String? projectId,
    PairingMetadata? metadata,
    Map<String, RequiredNamespace>? requiredNamespaces,
    Set<String>? recommendedWalletIds,
    ExcludedWalletState excludedWalletState = ExcludedWalletState.list,
    Set<String>? excludedWalletIds,
  }) : super(
          web3App: web3App,
          projectId: projectId,
          metadata: metadata,
          requiredNamespaces: requiredNamespaces,
          recommendedWalletIds: recommendedWalletIds,
          excludedWalletState: excludedWalletState,
          excludedWalletIds: excludedWalletIds,
        ) {
    blockchainApiUtils.instance = BlockchainApiUtils(
      projectId: this.projectId,
    );

    WalletConnectModalServices.registerInitFunction(
      'network_service',
      () async {
        await networkService.instance.init();
      },
    );
    WalletConnectModalServices.registerInitFunction(
      'storage_service',
      () async {
        await storageService.instance.init();
      },
    );
  }

  @override
  Future<void> init() async {
    await super.init();

    // Set the optional namespaces to everything in our asset util.
    final List<String> chainIds = [];
    for (final String id in ChainData.chainPresets.keys) {
      chainIds.add('eip155:$id');
    }
    final Map<String, RequiredNamespace> optionalNamespaces = {
      'eip155': RequiredNamespace(
        methods: EthUtil.ethMethods,
        chains: chainIds,
        events: EthUtil.ethEvents,
      ),
    };
    setOptionalNamespaces(
      optionalNamespaces: optionalNamespaces,
    );

    // Get the chainId of the chain we are connected to.
    if (session != null) {
      final String? chainId =
          storageService.instance.getString(selectedChainId);

      // If we had a chainId stored, use it!
      if (chainId != null) {
        if (ChainData.chainPresets.containsKey(chainId)) {
          await setSelectedChain(ChainData.chainPresets[chainId]!);
        }
      } else {
        // Otherwise, just get the first chainId from the namespaces of the session and use that
        final List<String> chainIds = NamespaceUtils.getChainIdsFromNamespaces(
          namespaces: session!.namespaces,
        );
        if (chainIds.isNotEmpty) {
          final String chainId = chainIds.first.split(':')[1];
          // If we have the chain in our presets, set it as the selected chain
          if (ChainData.chainPresets.containsKey(chainId)) {
            await setSelectedChain(ChainData.chainPresets[chainId]!);
          }
        }
      }
    }
  }

  @override
  Future<void> setSelectedChain(
    W3MChainInfo? chain, {
    bool switchChain = true,
  }) async {
    checkInitialized();

    if (chain?.chainId == selectedChain?.chainId) {
      return;
    }

    _chainBalance = null;
    _tokenImageUrl = null;

    // If the chain is null, disconnect and stop.
    if (chain == null) {
      _selectedChain = null;
      await disconnect();
      return;
    }

    // Store the chain for when we reload the app.
    await storageService.instance.setString(selectedChainId, chain.chainId);

    // Get the token/chain icon.
    _tokenImageUrl = explorerService.instance!.getAssetImageUrl(
      imageId: AssetUtil.getChainIconAssetId(
        chain.chainId,
      ),
    );

    // If we are connected, and the selected chain is not null, and the chains are different, switch chains.
    if (switchChain && // We want to swap the chain
        isConnected && // We are connected (Should mean the session isn't null)
        session != null && // Session isn't null (We double check)
        !NamespaceUtils.getChainIdsFromNamespaces(
          namespaces: session!.namespaces,
        ).contains(
            'eip155:${chain.chainId}') && // The session doesn't already have the chain
        _selectedChain != null && // The selected chain isn't null
        _selectedChain!.chainId !=
            chain.chainId) // The selected chain is different
    {
      // Then we swap/add the chain and launch the wallet
      _switchEthChain(selectedChain!, chain);
      await launchCurrentWallet();
    }

    _selectedChain = chain;

    // Load account data, this will notify listeners
    if (!await _loadAccountData()) {
      notifyListeners();
    }
  }

  /// PRIVATE FUNCTIONS ///

  @override
  void registerListeners() {
    super.registerListeners();
    // web3App!.onSessionUpdate.subscribe(_onSessionUpdate);
    web3App!.onSessionEvent.subscribe(_onSessionEvent);
  }

  @override
  void unregisterListeners() {
    super.unregisterListeners();
    // web3App!.onSessionUpdate.unsubscribe(_onSessionUpdate);
    web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
  }

  @override
  void onSessionConnect(SessionConnect? args) {
    _loadAccountData();

    super.onSessionConnect(args);
  }

  // void _onSessionUpdate(SessionUpdate? args) {
  //   LoggerUtil.logger.i(args?.namespaces);
  //   // _loadAccountData();
  // }

  void _onSessionEvent(SessionEvent? args) {
    if (args?.name == EthUtil.chainChanged) {
      if (ChainData.chainPresets.containsKey(args?.data.toString())) {
        setSelectedChain(
          ChainData.chainPresets[args?.data.toString()]!,
          switchChain: false,
        );
      }
    }
  }

  /// Loads account balance and avatar.
  /// Returns true if it was able to actually load data (i.e. there is a selected chain and session)
  Future<bool> _loadAccountData() async {
    // If there is no selected chain or session, stop. No account to load in.
    if (selectedChain == null || session == null) {
      return false;
    }

    // Get the chain balance.
    _chainBalance = await selectedChain!.ledgerService.getBalance(
      selectedChain!.rpcUrl,
      address!,
    );

    // Get the avatar, each chainId is just a number in string form.
    try {
      final blockchainId = await blockchainApiUtils.instance!.getIdentity(
        address!,
        int.parse(
          selectedChain!.chainId,
        ),
      );
      _avatarUrl = blockchainId.avatar;
    } catch (_) {
      // Couldn't load avatar, default to address icon
    }

    // Tell everyone we have loaded the things
    notifyListeners();

    return true;
  }

  Future<void> _switchEthChain(
    W3MChainInfo from,
    W3MChainInfo to,
  ) async {
    final int chainIdInt = int.parse(to.chainId);
    final String chainHex = chainIdInt.toRadixString(16);
    final String chainId = 'eip155:${from.chainId}';
    web3App!
        .request(
      topic: session!.topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: 'wallet_switchEthereumChain',
        params: [
          {
            'chainId': '0x$chainHex',
          },
        ],
      ),
    )
        .catchError(
      (e) {
        web3App!.request(
          topic: session!.topic,
          chainId: chainId,
          request: SessionRequestParams(
            method: 'wallet_addEthereumChain',
            params: [
              {
                'chainId': '0x$chainHex',
                'chainName': to.chainName,
                'nativeCurrency': {
                  'name': to.tokenName,
                  'symbol': to.tokenName,
                  'decimals': 18,
                },
                'rpcUrls': [to.rpcUrl],
              },
            ],
          ),
        );
      },
    );
  }
}
