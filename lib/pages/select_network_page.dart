import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/pages/about_networks.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';

import 'package:web3modal_flutter/widgets/lists/networks_grid.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/network_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/w3m_content_loading.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({
    super.key,
    required this.onTapNetwork,
  });
  final Function(W3MChainInfo)? onTapNetwork;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return Web3ModalNavbar(
      title: 'Select network',
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NetworkServiceItemsListener(
              builder: (context, initialised, items) {
                if (!initialised) {
                  return const ContentLoading();
                }
                return NetworksGrid(
                  viewPortRows: 3,
                  onTapNetwork: onTapNetwork,
                  itemList: items,
                );
              },
            ),
            Divider(
              color: themeData.colors.overgray005,
              height: 0.0,
            ),
            const SizedBox.square(dimension: 8.0),
            Text(
              'Your connected wallet may not support some of the networks available for this dApp',
              textAlign: TextAlign.center,
              style: themeData.textStyles.small500.copyWith(
                color: themeData.colors.foreground300,
              ),
            ),
            const SizedBox.square(dimension: 16.0),
            // TODO create widget
            GestureDetector(
              onTap: () async {
                widgetStack.instance.add(const AboutNetworks());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/help.svg',
                    package: 'web3modal_flutter',
                    colorFilter: ColorFilter.mode(
                      themeData.colors.blue100,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox.square(dimension: 4.0),
                  Text(
                    'What is a Network?',
                    textAlign: TextAlign.center,
                    style: themeData.textStyles.small600.copyWith(
                      color: themeData.colors.blue100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
