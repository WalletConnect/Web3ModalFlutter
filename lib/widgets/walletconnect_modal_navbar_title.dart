import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_theme.dart';

class WalletConnectModalNavbarTitle extends StatelessWidget {
  const WalletConnectModalNavbarTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: WalletConnectModalTheme.of(context).data.foreground100,
          ),
      textAlign: TextAlign.center,
    );
  }
}
