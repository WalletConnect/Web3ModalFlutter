import 'package:web3modal_flutter/services/blockchain_service/i_blockchain_service.dart';

class BlockChainServiceSingleton {
  IBlockChainService? instance;
}

final blockchainService = BlockChainServiceSingleton();
