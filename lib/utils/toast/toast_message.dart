import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';

enum ToastType { success, info, error }

class ToastMessage {
  final ToastType type;
  final String text;
  final Duration duration;
  final Completer completer = Completer();

  ToastMessage({
    required this.type,
    required this.text,
    this.duration = const Duration(milliseconds: 2500),
  });

  RoundedIcon icon(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    switch (type) {
      case ToastType.success:
        return RoundedIcon(
          assetPath: 'assets/icons/checkmark.svg',
          assetColor: themeColors.success100,
          circleColor: themeColors.success100.withOpacity(0.15),
          borderColor: Colors.transparent,
          padding: 6.0,
          size: 24.0,
        );
      case ToastType.error:
        return RoundedIcon(
          assetPath: 'assets/icons/warning.svg',
          assetColor: themeColors.error100,
          circleColor: themeColors.error100.withOpacity(0.15),
          borderColor: Colors.transparent,
          padding: 6.0,
          size: 24.0,
        );
      default:
        return RoundedIcon(
          assetPath: 'assets/icons/info.svg',
          assetColor: themeColors.accent100,
          circleColor: themeColors.accent100.withOpacity(0.15),
          borderColor: Colors.transparent,
          padding: 6.0,
          size: 24.0,
        );
    }
  }
}
