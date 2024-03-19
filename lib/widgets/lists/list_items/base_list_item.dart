import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class BaseListItem extends StatelessWidget {
  const BaseListItem({
    super.key,
    required this.child,
    this.trailing,
    this.onTap,
    this.padding,
    this.hightlighted = false,
  });
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsets? padding;
  final bool hightlighted;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return FilledButton(
      onPressed: onTap,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(
          const Size(1000.0, kListItemHeight),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          hightlighted ? themeColors.accenGlass015 : themeColors.grayGlass002,
        ),
        overlayColor: MaterialStateProperty.all<Color>(
          themeColors.grayGlass005,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiuses.radiusXS),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.all(0.0),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
