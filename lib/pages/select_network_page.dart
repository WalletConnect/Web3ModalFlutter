import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({
    super.key,
    required this.onSelect,
  });

  final void Function(W3MChainInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Select network',
      ),
      child: GridList(
        state: GridListState.long,
        provider: networkService.instance,
        onSelect: onSelect,
      ),
    );
  }
}
