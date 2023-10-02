import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';

class AccountListItem extends StatelessWidget {
  const AccountListItem({
    super.key,
    required this.title,
    this.titleStyle,
    this.iconWidget,
    this.iconPath,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBGColor,
    this.iconBorderColor,
  });
  final Widget? iconWidget;
  final String? iconPath;
  final TextStyle? titleStyle;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor, iconBGColor, iconBorderColor;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return BaseListItem(
      onTap: onTap,
      child: Row(
        children: [
          iconWidget ?? const SizedBox.shrink(),
          if (iconPath != null)
            RoundedIcon(
              assetPath: iconPath!,
              assetColor: iconColor,
              circleColor: iconBGColor,
              borderColor: iconBorderColor,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                title,
                style: titleStyle ??
                    themeData.textStyles.paragraph600.copyWith(
                      color: themeColors.foreground100,
                    ),
              ),
            ),
          ),
          trailing ??
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SvgPicture.asset(
                  'assets/icons/chevron_right.svg',
                  package: 'web3modal_flutter',
                  colorFilter: ColorFilter.mode(
                    themeColors.foreground200,
                    BlendMode.srcIn,
                  ),
                  width: 18.0,
                  height: 18.0,
                ),
              ),
        ],
      ),
    );
  }
}
