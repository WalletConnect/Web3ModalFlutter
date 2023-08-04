import 'package:web3modal_flutter/services/blockchain_api_service/i_blockchain_api_utils.dart';

class BlockchainApiUtilsSingleton {
  IBlockchainApiUtils? instance;
}

final blockchainApiUtils = BlockchainApiUtilsSingleton();
