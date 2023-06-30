import 'package:flutter/material.dart';
import 'package:web3modal_flutter/models/walletconnect_modal_theme_data.dart';

class WalletConnectModalTheme extends InheritedWidget {
  const WalletConnectModalTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final WalletConnectModalThemeData data;

  static WalletConnectModalTheme? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WalletConnectModalTheme>();
  }

  static WalletConnectModalTheme of(BuildContext context) {
    final WalletConnectModalTheme? result = maybeOf(context);
    assert(result != null, 'No Web3ModalTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
