import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/lists/grid_items/base_grid_item.dart';

class WalletGridItem extends StatelessWidget {
  const WalletGridItem({
    super.key,
    required this.image,
    required this.title,
    this.bottom,
    this.onTap,
    this.isSelected = false,
  });

  final Widget image;
  final String title;
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadiusXS),
              border: Border.all(
                color: isSelected
                    ? themeData.colors.overblue020
                    : themeData.colors.overgray010,
                width: 2.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: image,
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
