import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/services/explorer/i_explorer_service.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils_singleton.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/eth_util.dart';

class W3MService extends WalletConnectModalService implements IW3MService {
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
  }

  @override
  Future<void> init() async {
    _registerListeners();

    await super.init();

    // Get the chainId of the chain we are connected to.
    print(session);
    if (session != null) {
      final List<String> chainIds = NamespaceUtils.getChainIdsFromNamespaces(
        namespaces: session!.namespaces,
      );
      if (chainIds.isNotEmpty) {
        final String chainId = chainIds.first.split(':')[1];
        if (AssetUtil.chainPresets.containsKey(chainId)) {
          setSelectedChain(AssetUtil.chainPresets[chainId]!);
        }
      }
    }
  }

  @override
  // ignore: prefer_void_to_null
  Future<Null> onDispose() async {
    if (isInitialized) {
      _unregisterListeners();
    }
  }

  @override
  Future<void> setSelectedChain(
    W3MChainInfo? chain, {
    bool switchChain = true,
  }) async {
    if (chain?.chainId == selectedChain?.chainId) {
      return;
    }

    setDefaultChain(
      requiredNamespaces:
          chain?.requiredNamespaces ?? NamespaceConstants.ethereum,
    );

    _chainBalance = null;
    _tokenImageUrl = null;

    // If the chain is null, disconnect and stop.
    if (chain == null) {
      await disconnect();
      return;
    }

    // Get the token/chain icon.
    _tokenImageUrl = explorerService.instance!.getAssetImageUrl(
      imageId: AssetUtil.getChainIconAssetId(
        chain.chainId,
      ),
    );

    // If we are connected, and the selected chain is not null, and the chains are different, switch chains.
    if (switchChain &&
        isConnected &&
        _selectedChain != null &&
        _selectedChain!.chainId != chain.chainId) {
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

  void _registerListeners() {
    web3App!.onSessionConnect.subscribe(_onSessionConnect);
    web3App!.onSessionUpdate.subscribe(_onSessionUpdate);
    web3App!.onSessionEvent.subscribe(_onSessionEvent);
  }

  void _unregisterListeners() {
    web3App!.onSessionConnect.unsubscribe(_onSessionConnect);
    web3App!.onSessionUpdate.unsubscribe(_onSessionUpdate);
    web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
  }

  void _onSessionConnect(SessionConnect? args) {
    _loadAccountData();
  }

  void _onSessionUpdate(SessionUpdate? args) {
    LoggerUtil.logger.i(args?.namespaces);
    // _loadAccountData();
  }

  void _onSessionEvent(SessionEvent? args) {
    if (args?.name == EthUtil.chainChanged) {
      if (AssetUtil.chainPresets.containsKey(args?.data.toString())) {
        setSelectedChain(
          AssetUtil.chainPresets[args?.data.toString()]!,
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
