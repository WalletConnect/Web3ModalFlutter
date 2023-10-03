import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/grid_item_modal.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/widgets/lists/grid_items/wallet_grid_item.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';

import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';

class WalletsGrid extends StatelessWidget {
  const WalletsGrid({
    super.key,
    required this.itemList,
    this.onTapWallet,
  });
  final List<GridItem<W3MWalletInfo>> itemList;
  final Function(W3MWalletInfo walletInfo)? onTapWallet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kPadding12),
      child: Wrap(
        spacing: kGridAxisSpacing,
        runSpacing: kGridAxisSpacing,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: itemList
            .map(
              (info) => SizedBox(
                width: ResponsiveData.gridItemSzieOf(context).width,
                height: ResponsiveData.gridItemSzieOf(context).height,
                child: WalletGridItem(
                  onTap: () => onTapWallet?.call(info.data),
                  imageUrl: info.image,
                  title: info.title,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
