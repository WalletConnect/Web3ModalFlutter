import 'package:web3modal_flutter/services/blockchain_service/models/blockchain_identity.dart';

abstract class IBlockChainService {
  Future<void> init();

  /// Gets the name and avatar of a provided address on the given chain
  Future<BlockchainIdentity> getIdentity(String address);

  Future<dynamic> getRpcRequest({
    required String method,
    required List<dynamic> params,
    required String chain,
  });
}
