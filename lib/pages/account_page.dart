import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_message.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/widget_stack/widget_stack_singleton.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_provider.dart';
import 'package:web3modal_flutter/constants/constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/w3m_avatar.dart';
import 'package:web3modal_flutter/widgets/w3m_balance.dart';
import 'package:web3modal_flutter/widgets/w3m_circle_painter.dart';
import 'package:web3modal_flutter/widgets/w3m_connected_chip.dart';
import 'package:web3modal_flutter/widgets/w3m_disconnect_button.dart';
import 'package:web3modal_flutter/widgets/w3m_icon_button.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

class AccountPage extends StatelessWidget {
  const AccountPage()
      : super(
          key: Web3ModalConstants.accountPage,
        );

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);
    final IW3MService service =
        WalletConnectModalProvider.of(context).service as IW3MService;

    final Widget divider = Divider(
      color: themeData.overlay030,
      height: 1,
      thickness: 1,
    );

    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Select network',
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  W3MAvatar(
                    address: service.address ?? '',
                    avatar: null,
                  ),
                  Text(
                    Util.truncate(service.address ?? ''),
                  ),
                ],
              ),
              W3MConnectedChip(
                service: service,
              ),
            ],
          ),
          divider,
          W3MBalance(
            service: service,
          ),
          divider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              W3MIconButton(
                icon: W3MTokenImage(
                  token: service.tokenImageUrl,
                  isChain: true,
                ),
                text: service.selectedChain?.chainName ?? 'No Chain',
                onPressed: () {
                  widgetStack.instance.add(
                    const SelectNetworkPage(),
                  );
                },
              ),
              W3MIconButton(
                icon: W3MCirclePainter(
                  child: SvgPicture.asset(
                    'account_disconnect.svg',
                    package: 'web3modal_flutter',
                  ),
                ),
                text: StringConstants.copyAddress,
                onPressed: () {
                  _copyAddress(service);
                },
              ),
              W3MDisconnectButton(
                service: service,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyAddress(IW3MService service) {
    Clipboard.setData(
      ClipboardData(
        text: service.address ?? '',
      ),
    );
    toastUtils.instance.show(
      ToastMessage(
        type: ToastType.info,
        text: StringConstants.addressCopied,
      ),
    );
  }
}
