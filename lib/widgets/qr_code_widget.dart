import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage({
    super.key,
    required this.qrData,
    required this.logoPath,
  });

  final String qrData;
  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        // size: 300.0,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color: Colors.white,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: Colors.white,
        ),
        // embeddedImage: Image.asset(
        //   'assets/walletconnect_logo_white.png',
        //   package: 'web3modal_flutter',
        // ).image,
        // embeddedImageStyle: QrEmbeddedImageStyle(
        //   size: const Size(120, 120),
        //   color: Web3ModalTheme.of(context).backgroundColor,
        // ),
      ),
    );
  }
}
