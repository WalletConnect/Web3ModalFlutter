import 'package:flutter/material.dart';

class Web3ModalTheme extends InheritedWidget {
  const Web3ModalTheme({
    super.key,
    required this.backgroundColor,
    required this.accentColor,
    required this.fontFamily,
    required this.borderRadius,
    required super.child,
  });

  final Color backgroundColor;
  final Color accentColor;
  final String fontFamily;
  final double borderRadius;

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
