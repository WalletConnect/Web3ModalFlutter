import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/icons/themed_icon.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';

class AllWalletsItem extends StatelessWidget {
  const AllWalletsItem({
    super.key,
    this.title = 'All wallets',
    this.trailing,
    this.onTap,
  });
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return BaseListItem(
      onTap: onTap,
      child: Row(
        children: [
          LayoutBuilder(
            builder: (_, constraints) {
              return ThemedIcon(
                iconPath: 'assets/icons/dots.svg',
                size: constraints.maxHeight,
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                title,
                style: themeData.textStyles.paragraph500.copyWith(
                  color: themeColors.foreground100,
                ),
              ),
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
