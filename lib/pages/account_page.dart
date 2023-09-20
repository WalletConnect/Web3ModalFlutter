import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/constants.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_orb.dart';
import 'package:web3modal_flutter/widgets/buttons/address_copy_button.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/account_list_item.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';
import 'package:web3modal_flutter/widgets/text/w3m_balance.dart';

class AccountPage extends StatelessWidget {
  const AccountPage() : super(key: Web3ModalConstants.accountPage);

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final service = Web3ModalProvider.of(context).service;

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: kNavbarHeight / 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const W3MAccountOrb(size: 72.0),
                    const SizedBox.square(dimension: 12.0),
                    const W3MAddressWithCopyButton(),
                    const W3MBalanceText(),
                    if (service.hasBlockExplorer)
                      Column(
                        children: [
                          const SizedBox.square(dimension: 12.0),
                          SimpleIconButton(
                            onTap: () => service.launchBlockExplorer(),
                            leftIcon: 'assets/icons/compass.svg',
                            rightIcon: 'assets/icons/arrow_top_right.svg',
                            title: 'Block Explorer',
                            backgroundColor: themeData.colors.background125,
                            foregroundColor: themeData.colors.foreground150,
                            overlayColor: MaterialStateProperty.all<Color>(
                              themeData.colors.background200,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox.square(dimension: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AccountListItem(
                    iconWidget: RoundedIcon(
                      imageUrl: service.tokenImageUrl,
                      assetColor: themeData.colors.background100,
                    ),
                    title: service.selectedChain?.chainName ?? '',
                    onTap: () {
                      widgetStack.instance.add(SelectNetworkPage(
                        onTapNetwork: (W3MChainInfo chainInfo) {
                          // TODO FOCUS 2 check what happens when switch can not be done
                          service.setSelectedChain(
                            chainInfo,
                            switchChain: true,
                          );
                          widgetStack.instance.pop();
                        },
                      ));
                    },
                  ),
                ),
                const SizedBox.square(dimension: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AccountListItem(
                    iconPath: 'assets/icons/disconnect.svg',
                    trailing: const SizedBox.shrink(),
                    title: 'Disconnect',
                    titleStyle: themeData.textStyles.paragraph600.copyWith(
                      color: themeData.colors.foreground200,
                    ),
                    onTap: () async {
                      service.close();
                      await service.disconnect();
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: NavbarActionButton(
              asset: 'assets/icons/close.svg',
              action: () => service.close(),
            ),
          ),
        ],
      ),
    );
  }
}
