import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';

class ExplorerServiceSingleton {
  IExplorerService? instance;
}

final explorerService = ExplorerServiceSingleton();
