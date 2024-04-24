import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/pages/about_networks.dart';
import 'package:web3modal_flutter/pages/connet_network_page.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';

import 'package:web3modal_flutter/widgets/lists/networks_grid.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/network_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({
    this.onTapNetwork,
  }) : super(key: KeyConstants.selectNetworkPage);

  final Function(W3MChainInfo)? onTapNetwork;

  void _onSelectNetwork(BuildContext context, W3MChainInfo chainInfo) {
    final service = Web3ModalProvider.of(context).service;
    if (service.isConnected) {
      final approvedChains = service.session!.getApprovedChains() ?? [];
      final hasChainAlready = approvedChains.contains(
        chainInfo.namespace,
      );
      if (chainInfo.chainId == service.selectedChain?.chainId) {
        widgetStack.instance.pop();
      } else if (hasChainAlready || service.session!.sessionService.isMagic) {
        service.selectChain(chainInfo, switchChain: true);
        widgetStack.instance.pop();
      } else {
        widgetStack.instance.push(ConnectNetworkPage(chainInfo: chainInfo));
      }
    } else {
      onTapNetwork?.call(chainInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final service = Web3ModalProvider.of(context).service;
    final isSwitch = service.selectedChain != null;
    final isPortrait = ResponsiveData.isPortrait(context);
    final maxHeight =
        (ResponsiveData.gridItemSzieOf(context).height * 3) + (kPadding12 * 4);

    return Web3ModalNavbar(
      title: isSwitch ? 'Change network' : 'Select network',
      safeAreaLeft: true,
      safeAreaRight: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: isPortrait ? FlexFit.loose : FlexFit.tight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: NetworkServiceItemsListener(
                builder: (context, initialised, items) {
                  if (!initialised) {
                    return const ContentLoading();
                  }
                  return NetworksGrid(
                    onTapNetwork: (chainInfo) => _onSelectNetwork(
                      context,
                      chainInfo,
                    ),
                    itemList: items,
                  );
                },
              ),
            ),
          ),
          Divider(color: themeColors.grayGlass005, height: 0.0),
          const SizedBox.square(dimension: 8.0),
          Text(
            'Your connected wallet may not support some of the networks available for this dApp',
            textAlign: TextAlign.center,
            style: themeData.textStyles.small500.copyWith(
              color: themeColors.foreground300,
            ),
          ),
          SimpleIconButton(
            onTap: () {
              widgetStack.instance.push(
                const AboutNetworks(),
                event: ClickNetworkHelpEvent(),
              );
            },
            size: BaseButtonSize.small,
            leftIcon: 'assets/icons/help.svg',
            title: 'What is a network?',
            fontSize: 15.0,
            backgroundColor: Colors.transparent,
            foregroundColor: themeColors.accent100,
            overlayColor: MaterialStateProperty.all<Color>(
              themeColors.background200,
            ),
            withBorder: false,
          ),
        ],
      ),
    );
  }
}
