import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/services/utils/widget_stack/widget_stack_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';
import 'package:web3modal_flutter/constants/constants.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({
    required this.service,
  }) : super(
          key: Web3ModalConstants.selectNetworkPage,
        );

  final IW3MService service;

  @override
  Widget build(BuildContext context) {
    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Select network',
      ),
      child: GridList(
        state: GridListState.long,
        provider: networkService.instance,
        onSelect: _onChainSelect,
      ),
    );
  }

  void _onChainSelect(W3MChainInfo chain) {
    service.setSelectedChain(chain);
    widgetStack.instance.addDefault();
  }
}
