import 'package:flutter/material.dart';

import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/networks_grid.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/network_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/w3m_content_loading.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;

    return Web3ModalNavbar(
      title: 'Select network',
      child: SafeArea(
        child: NetworkServiceItemsListener(
          builder: (context, initialised, items) {
            if (!initialised) {
              return const ContentLoading();
            }
            return NetworksGrid(
              viewPortRows: 3,
              onTapNetwork: (info) {
                service.setSelectedChain(info);
                widgetStack.instance.addDefault();
              },
              itemList: items,
            );
          },
        ),
      ),
    );
  }
}
