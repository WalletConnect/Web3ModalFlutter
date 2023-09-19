import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/lists/grid_items/base_grid_item.dart';

class WalletGridItem extends StatelessWidget {
  const WalletGridItem({
    super.key,
    required this.title,
    this.imageWidget,
    this.imageUrl,
    this.bottom,
    this.onTap,
    this.isSelected = false,
  });

  final Widget? imageWidget;
  final String title;
  final String? imageUrl;
  final Widget? bottom;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return BaseGridItem(
      onTap: onTap,
      isSelected: isSelected,
      child: Column(
        children: <Widget>[
          imageWidget ??
              W3MWalletAvatar(
                borderRadius: kRadiusXS,
                imageUrl: imageUrl ?? '',
              ),
          const SizedBox(height: 4.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: themeData.textStyles.tiny500.copyWith(
                    color: isSelected
                        ? themeData.colors.blue100
                        : themeData.colors.foreground100,
                    height: 1.0,
                  ),
                ),
                bottom ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
