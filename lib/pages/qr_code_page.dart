import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/_unused/w3m_qr_code.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item_simple.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

import 'package:walletconnect_modal_flutter/services/utils/toast/toast_message.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_utils_singleton.dart';

// TODO FOCUS 4 better QR code
class QRCodePage extends StatelessWidget {
  const QRCodePage() : super(key: Web3ModalKeyConstants.qrCodePageKey);

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Web3ModalNavbar(
      title: 'WalletConnect',
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: QRCodeWidget(logoPath: 'assets/png/logo_wc.png'),
            ),
            Text(
              'Scan this QR code with your phone',
              style: themeData.textStyles.paragraph500.copyWith(
                color: themeData.colors.foreground100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WalletListItemSimple(
                title: 'Copy link',
                icon: 'assets/icons/copy.svg',
                onTap: () => _copyToClipboard(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final service = Web3ModalProvider.of(context).service;
    await Clipboard.setData(ClipboardData(text: service.wcUri!));
    toastUtils.instance.show(
      ToastMessage(
        type: ToastType.info,
        text: 'Link copied',
      ),
    );
  }
}
