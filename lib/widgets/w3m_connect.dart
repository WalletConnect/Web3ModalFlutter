import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/w3m_account_button.dart';

class W3MConnect extends StatelessWidget {
  const W3MConnect({
    super.key,
    required this.service,
    this.buttonRadius,
  });

  final IW3MService service;
  final double? buttonRadius;

  @override
  Widget build(BuildContext context) {
    return WalletConnectModalConnect(
      service: service,
      buttonRadius: buttonRadius,
      connectedWidget: W3MAccountButton(
        service: service,
      ),
    );
  }
}
