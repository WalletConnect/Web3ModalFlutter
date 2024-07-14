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
    this.subtitle,
    this.subtitleStyle,
    this.iconWidget,
    this.iconPath,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBGColor,
    this.iconBorderColor,
    this.hightlighted = false,
    this.flexible = false,
    this.padding,
  });
  final Widget? iconWidget;
  final String? iconPath;
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor, iconBGColor, iconBorderColor;
  final bool hightlighted;
  final bool flexible;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return BaseListItem(
      onTap: onTap,
      hightlighted: hightlighted,
      padding: padding,
      flexible: flexible,
      child: Row(
        children: [
          iconWidget ?? const SizedBox.shrink(),
          if (iconPath != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: RoundedIcon(
                assetPath: iconPath!,
                assetColor: iconColor,
                circleColor: iconBGColor,
                borderColor: iconBorderColor,
                borderRadius: radiuses.isSquare() ? 0.0 : null,
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle ??
                        themeData.textStyles.paragraph600.copyWith(
                          color: themeColors.foreground100,
                        ),
                  ),
                  if ((subtitle ?? '').isNotEmpty)
                    Text(
                      subtitle!,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle ??
                          themeData.textStyles.small400.copyWith(
                            color: themeColors.foreground150,
                          ),
                    ),
                ],
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
