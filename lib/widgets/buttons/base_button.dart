import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

enum BaseButtonSize {
  small,
  regular;

  double get height {
    switch (this) {
      case small:
        return 32.0;
      default:
        return 40.0;
    }
  }

  double get iconSize {
    switch (this) {
      case small:
        return 20.0;
      default:
        return 20.0;
    }
  }
}

class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    required this.child,
    required this.size,
    this.icon,
    this.onTap,
    this.buttonStyle,
    this.overridePadding,
  });
  final Widget child;
  final Widget? icon;
  final VoidCallback? onTap;
  final BaseButtonSize size;
  final ButtonStyle? buttonStyle;
  final MaterialStateProperty<EdgeInsetsGeometry?>? overridePadding;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final textStyle = size == BaseButtonSize.small
        ? themeData.textStyles.small600
        : themeData.textStyles.paragraph600;
    return FilledButton.icon(
      onPressed: onTap,
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle>(textStyle),
        minimumSize: MaterialStateProperty.all<Size>(Size(40.0, size.height)),
        maximumSize: MaterialStateProperty.all<Size>(Size(1000.0, size.height)),
        padding: overridePadding ??
            MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.only(left: 8.0, right: 16.0),
            ),
      ).merge(buttonStyle),
      label: child,
      icon: icon ?? const SizedBox.shrink(),
    );
  }
}
