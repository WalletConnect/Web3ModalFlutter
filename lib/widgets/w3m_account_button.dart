import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_button.dart';
import 'package:web3modal_flutter/constants/constants.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/w3m_address.dart';
import 'package:web3modal_flutter/widgets/w3m_avatar.dart';
import 'package:web3modal_flutter/widgets/w3m_balance.dart';

class W3MAccountButton extends StatefulWidget {
  const W3MAccountButton({
    super.key,
    required this.service,
    this.avatar,
  });

  final IW3MService service;
  final String? avatar;

  @override
  State<W3MAccountButton> createState() => _W3MAccountButtonState();
}

class _W3MAccountButtonState extends State<W3MAccountButton> {
  static const double _scaleDefault = 1.0;
  static const double _scaleTapped = 0.9;

  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Container(
      padding: const EdgeInsets.all(4.0),
      height: 40,
      decoration: BoxDecoration(
        color: themeData.colors.background200,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: themeData.colors.overgray025,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
            ),
            child: W3MBalance(service: widget.service),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            key: Web3ModalConstants.w3mAccountButton,
            onTapDown: (details) {
              setState(() {
                scale = _scaleTapped;
              });
            },
            onTapUp: (details) {
              setState(() {
                scale = _scaleDefault;
              });
            },
            onTapCancel: () {
              setState(() {
                scale = _scaleDefault;
              });
            },
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 100),
              child: WalletConnectModalButton(
                height: 32,
                padding: const EdgeInsets.only(
                  left: 4.0,
                  right: 10.0,
                  top: 3.0,
                  bottom: 3.0,
                ),
                onPressed: () {
                  widget.service.open(
                    context: context,
                    startWidget: const AccountPage(),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rainbow circle avatar (assuming you use the Image widget)
                    W3MAvatar(
                      service: widget.service,
                      size: 24,
                    ),
                    const SizedBox(width: 4.0),
                    // Address
                    W3MAddress(
                      service: widget.service,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
