import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({
    super.key,
    required this.onSelect,
  });

  final void Function(W3MChainInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Select network',
      ),
      child: GridList(
        state: GridListState.long,
        provider: networkService.instance,
        onSelect: onSelect,
        heightOverride: 380,
        longBottomSheetHeightOverride: 240,
        longBottomSheetAspectRatio: 0.85,
        itemAspectRatio: 0.75,
        createListItem: (info, height) {
          return Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              W3MTokenImage(
                imageUrl: info.image,
                isChain: true,
                size: 70,
                cornerRadius: 18,
              ),
              const SizedBox(height: 4.0),
              Text(
                info.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 12.0,
                  color: themeData.foreground100,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
