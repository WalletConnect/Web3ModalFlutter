import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_provider.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';

abstract class INetworkService extends GridListProvider<W3MChainInfo> {
  Future<void> init();
}
