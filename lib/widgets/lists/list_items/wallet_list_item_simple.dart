import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';

class WalletListItemSimple extends StatelessWidget {
  const WalletListItemSimple({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });
  final String title;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return BaseListItem(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            package: 'web3modal_flutter',
            colorFilter: ColorFilter.mode(
              themeColors.foreground200,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox.square(dimension: 8.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: themeData.textStyles.paragraph600.copyWith(
              color: themeColors.foreground200,
            ),
          ),
        ],
      ),
    );
  }
}
