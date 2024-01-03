import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';

class ExplorerServiceSingleton {
  late IExplorerService instance;
}

final explorerService = ExplorerServiceSingleton();
