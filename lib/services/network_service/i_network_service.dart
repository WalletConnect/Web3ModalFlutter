import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';

abstract class INetworkService {
  abstract ValueNotifier<List<GridItem<W3MChainInfo>>> itemList;
  abstract ValueNotifier<bool> initialized;

  Future<void> init();

  void filterList({String? query});
}
