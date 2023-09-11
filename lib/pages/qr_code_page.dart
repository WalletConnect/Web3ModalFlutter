import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';

import 'package:walletconnect_modal_flutter/services/utils/toast/toast_message.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/qr_code_widget.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_icon_button.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage() : super(key: Web3ModalKeyConstants.qrCodePageKey);

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;

    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Scan the code',
      ),
      actionWidget: WalletConnectIconButton(
        iconPath: 'assets/icons/copy.svg',
        onPressed: () {
          _copyQrCodeToClipboard(context);
        },
      ),
      child: QRCodeWidget(
        service: service,
        logoPath: 'assets/walletconnect_logo_white.png',
      ),
    );
  }

  Future<void> _copyQrCodeToClipboard(BuildContext context) async {
    final service = Web3ModalProvider.of(context).service;
    await Clipboard.setData(
      ClipboardData(
        text: service.wcUri!,
      ),
    );
    toastUtils.instance.show(
      ToastMessage(
        type: ToastType.info,
        text: 'Link copied',
      ),
    );
  }
}
