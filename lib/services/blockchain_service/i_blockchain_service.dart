import 'package:web3modal_flutter/services/blockchain_service/models/blockchain_identity.dart';

abstract class IBlockChainService {
  /// The project ID used when querying the API.
  String get projectId;

  /// Gets the name and avatar of a provided address on the given chain
  Future<BlockchainIdentity> getIdentity(String address, int chainId);

  // Future<JsonRpcResponse?> getBalance(String chainId, String address);

  // Future<String> fetchEnsName(String rpcUrl, String address);

  // Future<String> fetchEnsAvatar(String rpcUrl, String address);
}
