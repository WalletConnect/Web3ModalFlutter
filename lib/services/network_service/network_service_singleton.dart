import 'package:web3modal_flutter/services/network_service/i_network_service.dart';
import 'package:web3modal_flutter/services/network_service/network_service.dart';

class NetworkServiceSingleton {
  INetworkService instance;

  NetworkServiceSingleton() : instance = NetworkService();
}

final networkService = NetworkServiceSingleton();
