import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_message.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/widget_stack/widget_stack_singleton.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_provider.dart';
import 'package:web3modal_flutter/constants/constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/w3m_address.dart';
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
      color: themeData.overlay010,
      height: 1,
      thickness: 1,
    );

    const double paddingHorizontal = 20;
    const double paddingVertical = 10;

    return Container(
      padding: const EdgeInsets.only(
        top: paddingVertical,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: paddingHorizontal,
                  top: paddingVertical,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    W3MAvatar(
                      service: service,
                      size: 60,
                    ),
                    const SizedBox(
                      height: paddingVertical,
                    ),
                    W3MAddress(
                      service: service,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: themeData.foreground100,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: paddingVertical,
                  right: paddingHorizontal,
                ),
                child: W3MConnectedChip(
                  service: service,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: paddingVertical,
          ),
          divider,
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: paddingVertical,
            ),
            child: W3MBalance(
              service: service,
            ),
          ),
          divider,
          Padding(
            padding: const EdgeInsets.only(
              left: paddingHorizontal,
              right: paddingHorizontal,
              top: paddingVertical,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListenableBuilder(
                    listenable: service,
                    builder: (BuildContext context, Widget? child) {
                      return W3MIconButton(
                        key: Web3ModalConstants.chainSwapButton,
                        icon: W3MTokenImage(
                          imageUrl: service.tokenImageUrl,
                          isChain: true,
                          size: 34,
                        ),
                        text: service.selectedChain?.chainName ??
                            StringConstants.noChain,
                        onPressed: () {
                          widgetStack.instance.add(
                            SelectNetworkPage(
                              onSelect: (chain) {
                                service.setSelectedChain(chain);
                                widgetStack.instance.pop();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  child: W3MIconButton(
                    key: Web3ModalConstants.addressCopyButton,
                    icon: W3MCirclePainter(
                      child: SvgPicture.asset(
                        'assets/account_copy.svg',
                        package: 'web3modal_flutter',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    text: StringConstants.copyAddress,
                    onPressed: () {
                      _copyAddress(service);
                    },
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  child: W3MDisconnectButton(
                    service: service,
                  ),
                ),
              ],
            ),
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
