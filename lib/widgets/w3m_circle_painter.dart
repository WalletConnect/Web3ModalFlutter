import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';

class W3MCirclePainter extends StatelessWidget {
  const W3MCirclePainter({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeData.primary100,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
