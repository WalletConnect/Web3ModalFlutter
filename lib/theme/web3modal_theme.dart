import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/web3modal_theme_data.dart';

class Web3ModalTheme extends InheritedWidget {
  const Web3ModalTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final Web3ModalThemeData data;

  bool get isDarkMode =>
      data.colors.blue100 == Web3ModalThemeData.darkMode.colors.blue100;

  static Web3ModalTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Web3ModalTheme>();
  }

  static Web3ModalTheme of(BuildContext context) {
    final Web3ModalTheme? result = maybeOf(context);
    assert(result != null, 'No Web3ModalTheme found in context');
    return result!;
  }

  static Web3ModalThemeData getDataOf(BuildContext context) {
    final Web3ModalTheme? theme = maybeOf(context);
    return theme?.data ?? Web3ModalThemeData.lightMode;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
