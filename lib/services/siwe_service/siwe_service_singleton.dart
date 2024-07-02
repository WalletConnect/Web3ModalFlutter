import 'package:web3modal_flutter/services/siwe_service/i_siwe_service.dart';

class SiweServiceSingleton {
  ISiweService? instance;
}

final siweService = SiweServiceSingleton();
