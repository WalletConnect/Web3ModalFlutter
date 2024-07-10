import 'package:web3modal_flutter/services/blockchain_service/i_blockchain_service.dart';

class BlockChainServiceSingleton {
  late IBlockChainService instance;
}

final blockchainService = BlockChainServiceSingleton();
