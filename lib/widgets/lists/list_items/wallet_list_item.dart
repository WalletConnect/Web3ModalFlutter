import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';

class WalletListItem extends StatelessWidget {
  const WalletListItem({
    super.key,
    required this.title,
    this.imageWidget,
    this.imageUrl,
    this.trailing,
    this.onTap,
  });
  final Widget? imageWidget;
  final String title;
  final String? imageUrl;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return BaseListItem(
      onTap: onTap,
      child: Row(
        children: [
          imageWidget ??
              W3MListAvatar(
                borderRadius: radiuses.radius2XS,
                imageUrl: imageUrl,
              ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                title,
                style: themeData.textStyles.paragraph500.copyWith(
                  color: onTap == null
                      ? themeColors.foreground200
                      : themeColors.foreground100,
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
