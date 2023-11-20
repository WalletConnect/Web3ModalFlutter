import 'package:flutter/material.dart';
import 'package:web3modal_flutter/models/grid_item.dart';

import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/network_service/network_service_singleton.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';

class NetworkServiceItemsListener extends StatelessWidget {
  const NetworkServiceItemsListener({
    super.key,
    required this.builder,
  });
  final Function(
    BuildContext context,
    bool initialised,
    List<GridItem<W3MChainInfo>> items,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: networkService.instance.initialized,
      builder: (context, bool initialised, _) {
        if (!initialised) {
          return builder(context, initialised, []);
        }
        return ValueListenableBuilder(
          valueListenable: networkService.instance.itemList,
          builder: (context, items, _) {
            final service = Web3ModalProvider.of(context).service;
            final supportedChains = service.getAvailableChains();
            final parsedItems = supportedChains == null
                ? items
                : items.map((e) {
                    return e.copyWith(
                      disabled: !supportedChains.contains(e.data.namespace),
                    );
                  }).toList()
              ..sort((a, b) {
                final disabledA = a.disabled ? 0 : 1;
                final disabledB = b.disabled ? 0 : 1;
                return disabledB.compareTo(disabledA);
              });
            return builder(context, initialised, parsedItems);
          },
        );
      },
    );
  }
}
