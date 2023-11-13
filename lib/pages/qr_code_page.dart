import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/w3m_qr_code.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage() : super(key: Web3ModalKeyConstants.qrCodePageKey);

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  IW3MService? _service;
  Widget? _qrQodeWidget;
  //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _service = Web3ModalProvider.of(context).service;
      _service!.addListener(_buildWidget);
      _service!.onPairingExpire.subscribe(_onPairingExpire);
      _service?.onWalletConnectionError.subscribe(_onError);
      await _service!.buildConnectionUri();
    });
  }

  void _buildWidget() => setState(() {
        _qrQodeWidget = QRCodeWidget(
          uri: _service!.wcUri!,
          logoPath: 'assets/png/logo_wc.png',
        );
      });

  void _onPairingExpire(EventArgs? args) async {
    await _service!.buildConnectionUri();
    setState(() {});
  }

  void _onError(EventArgs? args) {
    _showUserRejection();
  }

  @override
  void dispose() async {
    _service?.onWalletConnectionError.unsubscribe(_onError);
    _service!.onPairingExpire.unsubscribe(_onPairingExpire);
    _service!.removeListener(_buildWidget);
    _service!.expirePreviousInactivePairings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final isPortrait = ResponsiveData.isPortrait(context);

    return Web3ModalNavbar(
      title: 'WalletConnect',
      body: SingleChildScrollView(
        scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
        child: Flex(
          direction: isPortrait ? Axis.vertical : Axis.horizontal,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: _qrQodeWidget ??
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radiuses.radiusL),
                        color: themeColors.grayGlass005,
                      ),
                    ),
                  ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: isPortrait
                    ? ResponsiveData.maxWidthOf(context)
                    : (ResponsiveData.maxHeightOf(context) -
                        kNavbarHeight -
                        32.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Scan this QR code with your phone',
                    textAlign: TextAlign.center,
                    style: themeData.textStyles.paragraph500.copyWith(
                      color: themeColors.foreground100,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: kPadding12),
                    child: SimpleIconButton(
                      onTap: () => _copyToClipboard(context),
                      leftIcon: 'assets/icons/copy_14.svg',
                      iconSize: 13.0,
                      title: 'Copy link',
                      fontSize: 14.0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: themeColors.foreground200,
                      overlayColor: MaterialStateProperty.all<Color>(
                        themeColors.background200,
                      ),
                      withBorder: false,
                    ),
                  ),
                ],
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
      ToastMessage(type: ToastType.success, text: 'Link copied'),
    );
  }

  void _showUserRejection() => toastUtils.instance.show(
        ToastMessage(type: ToastType.error, text: 'User rejected'),
      );
}
