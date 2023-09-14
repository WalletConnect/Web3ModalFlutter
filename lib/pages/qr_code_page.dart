import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item_simple.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_message.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_utils_singleton.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage() : super(key: Web3ModalKeyConstants.qrCodePageKey);

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Web3ModalNavbar(
      title: 'QR Code',
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _QRCodeWidget(),
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

class _QRCodeWidget extends StatefulWidget {
  @override
  State<_QRCodeWidget> createState() => __QRCodeWidgetState();
}

class __QRCodeWidgetState extends State<_QRCodeWidget> {
  IW3MService? _service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _service = Web3ModalProvider.of(context).service;
      await _service?.rebuildConnectionUri();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    bool isLongBottomSheet = platformUtils.instance.isLongBottomSheet(
      MediaQuery.of(context).orientation,
    );
    double qrSize = MediaQuery.of(context).size.height - 200;
    double marginAndPadding = isLongBottomSheet ? 1.0 : 8.0;

    if (_service == null) {
      double size = min(
            qrSize,
            MediaQuery.of(context).size.width,
          ) -
          marginAndPadding * 2;
      return Container(
        width: size,
        height: size,
        margin: EdgeInsets.all(marginAndPadding),
        padding: EdgeInsets.all(marginAndPadding),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: themeData.colors.blue100,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusL),
      child: ColoredBox(
        color: Colors.white,
        child: QrImageView(
          data: _service!.wcUri!,
          version: QrVersions.auto,
          padding: const EdgeInsets.all(16.0),
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Colors.black,
          ),
          embeddedImage: const AssetImage(
            'assets/wc_logo.jpg',
            package: 'web3modal_flutter',
          ),
          embeddedImageStyle: const QrEmbeddedImageStyle(
            size: Size(80.0, 80.0),
          ),
          gapless: true,
          embeddedImageEmitsError: true,
        ),
      ),
    );
  }
}
