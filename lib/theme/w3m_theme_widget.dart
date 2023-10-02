import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_colors.dart';
import 'package:web3modal_flutter/theme/w3m_theme_data.dart';

class Web3ModalTheme extends InheritedWidget {
  const Web3ModalTheme({
    super.key,
    required super.child,
    this.data,
    this.isDarkMode = false,
  });

  final Web3ModalThemeData? data;
  final bool isDarkMode;

  static Web3ModalTheme of(BuildContext context) {
    final Web3ModalTheme? result = maybeOf(context);
    assert(result != null, 'No Web3ModalTheme found in context');
    return result!;
  }

  static Web3ModalTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Web3ModalTheme>();
  }

  static Web3ModalThemeData getDataOf(BuildContext context) {
    final Web3ModalTheme? theme = maybeOf(context);
    return theme?.data ?? const Web3ModalThemeData();
  }

  static Web3ModalColors colorsOf(BuildContext context) {
    final Web3ModalTheme? theme = maybeOf(context);
    if (theme?.isDarkMode == true) {
      return theme?.data?.darkColors ?? Web3ModalColors.darkMode;
    }
    return theme?.data?.lightColors ?? Web3ModalColors.lightMode;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
