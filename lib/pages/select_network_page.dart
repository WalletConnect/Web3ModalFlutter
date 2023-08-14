import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/services/utils/widget_stack/widget_stack_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_provider.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final IW3MService service =
        WalletConnectModalProvider.of(context).service as IW3MService;

    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Select network',
      ),
      child: GridList(
        state: GridListState.long,
        provider: networkService.instance,
        onSelect: (W3MChainInfo chain) {
          service.setSelectedChain(chain);
          widgetStack.instance.addDefault();
        },
      ),
    );
  }
}
