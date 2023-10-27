import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
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

class AccountPage extends StatefulWidget {
  const AccountPage() : super(key: Web3ModalKeyConstants.accountPage);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  IW3MService? _service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service = Web3ModalProvider.of(context).service;
      _service?.addListener(_rebuild);
      _rebuild();
    });
  }

  void _rebuild() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rebuild();
    }
  }

  @override
  void dispose() {
    _service?.removeListener(_rebuild);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: kNavbarHeight / 2,
              left: kPadding12,
              right: kPadding12,
              bottom: kPadding12,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const W3MAccountOrb(size: 72.0),
                      const SizedBox.square(dimension: kPadding12),
                      const W3MAddressWithCopyButton(),
                      const W3MBalanceText(),
                      Visibility(
                        visible: _service?.selectedChain?.blockExplorer != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: kPadding12),
                          child: SimpleIconButton(
                            onTap: () => _service?.launchBlockExplorer(),
                            leftIcon: 'assets/icons/compass.svg',
                            rightIcon: 'assets/icons/arrow_top_right.svg',
                            title: 'Block Explorer',
                            backgroundColor: themeColors.background125,
                            foregroundColor: themeColors.foreground150,
                            overlayColor: MaterialStateProperty.all<Color>(
                              themeColors.background200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox.square(dimension: 20.0),
                  AccountListItem(
                    iconWidget: RoundedIcon(
                      imageUrl: _service?.tokenImageUrl,
                      assetColor: themeColors.background100,
                    ),
                    title: _service?.selectedChain?.chainName ?? '',
                    onTap: () {
                      widgetStack.instance.push(SelectNetworkPage(
                        onTapNetwork: (W3MChainInfo chainInfo) {
                          _service?.selectChain(chainInfo, switchChain: true);
                          widgetStack.instance.pop();
                        },
                      ));
                    },
                  ),
                  const SizedBox.square(dimension: kPadding8),
                  AccountListItem(
                    iconPath: 'assets/icons/disconnect.svg',
                    trailing: const SizedBox.shrink(),
                    title: 'Disconnect',
                    titleStyle: themeData.textStyles.paragraph600.copyWith(
                      color: themeColors.foreground200,
                    ),
                    onTap: () async {
                      _service?.closeModal();
                      await _service?.disconnect();
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: NavbarActionButton(
              asset: 'assets/icons/close.svg',
              action: () => _service?.closeModal(),
            ),
          ),
        ],
      ),
    );
  }
}
