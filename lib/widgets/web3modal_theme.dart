import 'package:flutter/material.dart';
import 'package:web3modal_flutter/models/web3modal_theme_data.dart';

class Web3ModalTheme extends InheritedWidget {
  const Web3ModalTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final Web3ModalThemeData data;

  static Web3ModalTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Web3ModalTheme>();
  }

  static Web3ModalTheme of(BuildContext context) {
    final Web3ModalTheme? result = maybeOf(context);
    assert(result != null, 'No Web3ModalTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
