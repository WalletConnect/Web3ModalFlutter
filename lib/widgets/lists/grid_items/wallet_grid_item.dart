import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/constants.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
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
    this.isNetwork = false,
  });

  final Widget? imageWidget;
  final String title;
  final String? imageUrl;
  final Widget? bottom;
  final VoidCallback? onTap;
  final bool isSelected, isNetwork;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return BaseGridItem(
      onTap: onTap,
      isSelected: isSelected,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: imageWidget ??
                  W3MListAvatar(
                    borderRadius: radiuses.radiusXS,
                    imageUrl: imageUrl,
                    isNetwork: isNetwork,
                    color: isSelected ? themeColors.accent100 : null,
                    disabled: isNetwork && onTap == null,
                  ),
            ),
          ),
          const SizedBox(height: 2.0),
          Padding(
            padding: const EdgeInsets.only(
              top: kPadding6,
              left: kPadding8,
              right: kPadding8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: radiuses.isCircular()
                      ? TextOverflow.fade
                      : TextOverflow.ellipsis,
                  softWrap: !radiuses.isCircular(),
                  style: themeData.textStyles.tiny500.copyWith(
                    color: isSelected
                        ? themeColors.accent100
                        : themeColors.foreground100,
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
