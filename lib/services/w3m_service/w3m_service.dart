import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/services/explorer/i_explorer_service.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils_singleton.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';

class W3MService extends WalletConnectModalService implements IW3MService {
  W3MChainInfo? _selectedChain;
  @override
  W3MChainInfo? get selectedChain => _selectedChain;

  double _chainBalance = -1;
  @override
  double get chainBalance => _chainBalance;

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

    WalletConnectModalServices.addInitFunction(() {
      networkService.instance.init();
    });
  }

  @override
  void setSelectedChain(W3MChainInfo? chain) {
    _selectedChain = chain;

    setDefaultChain(
      requiredNamespaces:
          chain?.requiredNamespaces ?? NamespaceConstants.ethereum,
    );

    _chainBalance = -1;

    if (isConnected) {
      // TODO: Request that the wallet change the chain.
    }

    notifyListeners();
  }

  Future<void> _updateChainBalance() async {
    // TODO: Query the chain balance
  }
}
