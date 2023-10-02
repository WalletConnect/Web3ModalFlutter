import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';

class AllWalletsItem extends StatelessWidget {
  const AllWalletsItem({
    super.key,
    this.trailing,
    this.onTap,
  });
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return BaseListItem(
      onTap: onTap,
      child: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SvgPicture.asset(
                AssetUtil.getThemedAsset(context, 'all_wallets.svg'),
                package: 'web3modal_flutter',
                height: constraints.maxHeight,
                width: constraints.maxHeight,
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'All Wallets',
                style: themeData.textStyles.paragraph500.copyWith(
                  color: themeData.colors.foreground100,
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
