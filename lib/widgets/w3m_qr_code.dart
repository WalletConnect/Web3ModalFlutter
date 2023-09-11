import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';

class QRCodeWidget extends StatefulWidget {
  const QRCodeWidget({
    super.key,
    required this.service,
    required this.logoPath,
  });

  final IW3MService service;
  final String logoPath;

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {
  bool _initialized = false;
  String _qrCode = '';

  @override
  void initState() {
    super.initState();
    // _qrCode = widget.service.wcUri!;

    _initialize();

    // widget.service.addListener(_qrCodeChanged);
  }

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }

    await widget.service.rebuildConnectionUri();

    setState(() {
      _qrCode = widget.service.wcUri!;
      _initialized = true;
    });
  }

  // @override
  // void dispose() {
  //   widget.service.removeListener(_qrCodeChanged);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    bool isLongBottomSheet = platformUtils.instance.isLongBottomSheet(
      MediaQuery.of(context).orientation,
    );
    double qrSize = MediaQuery.of(context).size.height - 200;
    double marginAndPadding = isLongBottomSheet ? 1.0 : 8.0;

    if (!_initialized) {
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusL),
      ),
      constraints: isLongBottomSheet
          ? BoxConstraints(
              maxHeight: qrSize,
              maxWidth: qrSize,
            )
          : null,
      margin: EdgeInsets.all(marginAndPadding),
      padding: EdgeInsets.all(marginAndPadding),
      child: Center(
        child: QrImageView(
          data: _qrCode,
          version: QrVersions.auto,
          // size: 300.0,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Colors.black,
          ),
          // gapless: true,
          // embeddedImage: const AssetImage(
          //   'assets/walletconnect_logo_blue_solid_background.png',
          //   package: 'walletconnect_modal_flutter',
          //   // color: themeData.primary100,
          // ),
          // embeddedImageStyle: const QrEmbeddedImageStyle(
          //   size: Size(80, 80),
          //   // color: themeData.primary100,
          // ),
          embeddedImageEmitsError: true,
        ),
      ),
    );
  }
}
