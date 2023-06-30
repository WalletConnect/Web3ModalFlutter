import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_theme.dart';

class WalletConnectModalButton extends StatelessWidget {
  final Widget child;
  final void Function() onPressed;

  const WalletConnectModalButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalTheme theme = WalletConnectModalTheme.of(context);

    return MaterialButton(
      onPressed: onPressed,
      color: theme.data.primary100,
      focusColor: theme.data.primary090,
      hoverColor: theme.data.primary090,
      highlightColor: theme.data.primary080,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          theme.data.radius4XS,
        ),
      ),
      child: child,
    );
  }
}
