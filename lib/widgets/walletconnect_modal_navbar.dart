import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_theme.dart';

class WalletConnectModalNavBar extends StatelessWidget {
  const WalletConnectModalNavBar({
    Key? key,
    required this.title,
    this.onBack,
    this.actionWidget,
    required this.child,
  }) : super(key: key);

  final Widget title;
  final VoidCallback? onBack;
  final Widget? actionWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 60,
                child: Row(
                  children: [
                    if (onBack != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: WalletConnectModalTheme.of(context)
                            .data
                            .foreground100,
                        onPressed: onBack,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: title,
              ),
              SizedBox(
                width: 60,
                child: Row(
                  children: [
                    if (actionWidget != null) actionWidget!,
                  ],
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
