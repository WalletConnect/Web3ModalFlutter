import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/w3m_circle_painter.dart';
import 'package:web3modal_flutter/widgets/w3m_icon_button.dart';

class W3MDisconnectButton extends StatefulWidget {
  const W3MDisconnectButton({
    super.key,
    required this.service,
  });

  final IW3MService service;

  @override
  State<W3MDisconnectButton> createState() => _W3MDisconnectButtonState();
}

class _W3MDisconnectButtonState extends State<W3MDisconnectButton> {
  bool _disconnecting = false;

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return W3MIconButton(
      icon: W3MCirclePainter(
        child: _disconnecting
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  color: themeData.foreground100,
                  strokeWidth: 2,
                ),
              )
            : SvgPicture.asset(
                'assets/account_disconnect.svg',
                package: 'web3modal_flutter',
                colorFilter: ColorFilter.mode(
                  themeData.foreground100,
                  BlendMode.srcIn,
                ),
              ),
      ),
      text: StringConstants.disconnect,
      onPressed: _disconnect,
    );
  }

  Future<void> _disconnect() async {
    if (_disconnecting) {
      return;
    }

    setState(() {
      _disconnecting = true;
    });
    widget.service.close();
    await widget.service.disconnect();
  }
}
