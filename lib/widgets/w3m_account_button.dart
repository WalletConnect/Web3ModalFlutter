import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_provider.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/utils/util.dart';
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

    IW3MService w3mService =
        WalletConnectModalProvider.of(context).service as IW3MService;

    return Container(
      color: themeData.background100,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(
            themeData.radius3XS,
          ),
        ),
        border: Border.all(
          color: themeData.overlay010,
          width: 2.0,
        ),
      ),
      child: Row(
        children: [
          W3MBalance(service: w3mService),
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
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(1.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      100,
                    ),
                  ),
                ),
                color: themeData.primary100,
                child: Row(
                  children: [
                    // Rainbow circle avatar (assuming you use the Image widget)
                    W3MAvatar(
                      address: widget.service.address!,
                      avatar: widget.avatar,
                    ),
                    const SizedBox(height: 10.0),
                    // Address
                    Text(
                      Util.truncate(widget.service.address!),
                      style: TextStyle(
                        color: themeData.foreground100,
                      ),
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
