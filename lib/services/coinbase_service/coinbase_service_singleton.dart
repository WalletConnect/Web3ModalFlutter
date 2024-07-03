import 'package:web3modal_flutter/services/coinbase_service/i_coinbase_service.dart';

class CoinbaseServiceSingleton {
  late ICoinbaseService instance;
}

final coinbaseService = CoinbaseServiceSingleton();
