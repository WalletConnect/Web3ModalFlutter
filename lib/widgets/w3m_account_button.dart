import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
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
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: themeData.background300,
        borderRadius: BorderRadius.all(
          Radius.circular(
            themeData.radiusXS,
          ),
        ),
        border: Border.all(
          color: themeData.overlay030,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          W3MBalance(service: widget.service),
          const SizedBox(width: 8),
          GestureDetector(
            onTapDown: (details) {
              setState(() {
                scale = 0.75;
              });
            },
            onTapUp: (details) {
              setState(() {
                scale = 1.0;
              });
            },
            onTap: () {
              widget.service.open(
                context: context,
                startWidget: const AccountPage(),
              );
            },
            // TODO: Make this scale over time
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.only(
                  left: 4.0,
                  right: 8.0,
                  top: 4.0,
                  bottom: 4.0,
                ),
                decoration: BoxDecoration(
                  color: themeData.primary100,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      100,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rainbow circle avatar (assuming you use the Image widget)
                    W3MAvatar(
                      service: widget.service,
                      size: 30,
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
