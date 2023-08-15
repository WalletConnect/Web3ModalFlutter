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
    if (session != null && session!.requiredNamespaces != null) {
      final List<String> chainIds =
          NamespaceUtils.getChainIdsFromRequiredNamespaces(
        requiredNamespaces: session!.requiredNamespaces!,
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
  Future<void> setSelectedChain(W3MChainInfo? chain) async {
    _selectedChain = chain;

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

    if (isConnected) {
      // TODO: Request that the wallet change the chain.

      _loadAccountData();
    }

    notifyListeners();
  }

  /// PRIVATE FUNCTIONS ///

  void _registerListeners() {
    web3App!.onSessionConnect.subscribe(_onSessionConnect);
  }

  void _unregisterListeners() {
    web3App!.onSessionConnect.unsubscribe(_onSessionConnect);
  }

  void _onSessionConnect(SessionConnect? args) {
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    // If there is no selected chain or session, stop. No account to load in.
    if (selectedChain == null || session == null) {
      return;
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
  }
}
