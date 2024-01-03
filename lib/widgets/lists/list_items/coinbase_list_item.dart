import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';

class CoinbaseListItem extends StatelessWidget {
  const CoinbaseListItem({
    super.key,
    this.title = 'Coinbase',
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
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return BaseListItem(
      onTap: onTap,
      child: Row(
        children: [
          W3MListAvatar(
            borderRadius: radiuses.radius2XS,
            imageUrl:
                'https://play-lh.googleusercontent.com/wrgUujbq5kbn4Wd4tzyhQnxOXkjiGqq39N4zBvCHmxpIiKcZw_Pb065KTWWlnoejsg=w240-h480',
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
