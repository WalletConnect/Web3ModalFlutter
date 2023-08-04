import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_identity.dart';

abstract class IBlockchainApiUtils {
  static const blockchainApiEndpoint = 'https://rpc.walletconnect.com';

  /// The root URI of the blockchain API.
  String get blockchainApiUriRoot;

  /// The project ID used when querying the API.
  String get projectId;

  /// Gets the name and avatar of a provided address on the given chain
  Future<BlockchainIdentity> getIdentity(
    String address,
    int chainId,
  );
}
