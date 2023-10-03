import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';

class WalletConnectItem extends StatelessWidget {
  const WalletConnectItem({
    super.key,
    this.onTap,
  });
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
            builder: (context, constraints) {
              return SvgPicture.asset(
                AssetUtil.getThemedAsset(context, 'logo_walletconnect.svg'),
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
                'WalletConnect',
                style: themeData.textStyles.paragraph500.copyWith(
                  color: themeColors.foreground100,
                ),
              ),
            ),
          ),
          WalletItemChip(
            value: ' QR CODE ',
            color: themeColors.accenGlass015,
            textStyle: themeData.textStyles.micro700.copyWith(
              color: themeColors.accent100,
            ),
          ),
        ],
      ),
    );
  }
}
