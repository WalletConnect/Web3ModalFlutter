import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/_unused/disconnect/w3m_circle_painter.dart';
import 'package:web3modal_flutter/widgets/_unused/disconnect/w3m_icon_button.dart';

class W3MDisconnectButton extends StatefulWidget {
  const W3MDisconnectButton({
    required this.service,
  }) : super(key: Web3ModalKeyConstants.disconnectButton);

  final IW3MService service;

  @override
  State<W3MDisconnectButton> createState() => _W3MDisconnectButtonState();
}

class _W3MDisconnectButtonState extends State<W3MDisconnectButton> {
  bool _disconnecting = false;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    return W3MIconButton(
      icon: W3MCirclePainter(
        child: _disconnecting
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  color: themeColors.inverse100,
                  strokeWidth: 2,
                ),
              )
            : SvgPicture.asset(
                'assets/account_disconnect.svg',
                package: 'web3modal_flutter',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
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
    widget.service.closeModal();
    await widget.service.disconnect();
  }
}
