import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
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
  const AccountPage() : super(key: Web3ModalKeyConstants.accountPage);

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
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
                    Visibility(
                      visible: service.selectedChain?.blockExplorer != null,
                      child: Column(
                        children: [
                          const SizedBox.square(dimension: 12.0),
                          SimpleIconButton(
                            onTap: () => service.launchBlockExplorer(),
                            leftIcon: 'assets/icons/compass.svg',
                            rightIcon: 'assets/icons/arrow_top_right.svg',
                            title: 'Block Explorer',
                            backgroundColor: themeColors.background125,
                            foregroundColor: themeColors.foreground150,
                            overlayColor: MaterialStateProperty.all<Color>(
                              themeColors.background200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AccountListItem(
                    iconWidget: RoundedIcon(
                      imageUrl: service.tokenImageUrl,
                      assetColor: themeColors.background100,
                    ),
                    title: service.selectedChain?.chainName ?? '',
                    onTap: () {
                      widgetStack.instance.add(SelectNetworkPage(
                        onTapNetwork: (W3MChainInfo chainInfo) {
                          // TODO check what happens when switch can not be done
                          service.selectChain(chainInfo, switchChain: true);
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
                      color: themeColors.foreground200,
                    ),
                    onTap: () async {
                      service.closeModal();
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
              action: () => service.closeModal(),
            ),
          ),
        ],
      ),
    );
  }
}
