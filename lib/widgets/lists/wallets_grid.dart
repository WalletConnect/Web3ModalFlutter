import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/lists/grid_items/wallet_grid_item.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';

import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';

class WalletsGrid extends StatelessWidget {
  const WalletsGrid({
    super.key,
    required this.itemList,
    this.onTapWallet,
    this.isPaginating = false,
  });
  final List<GridItem<W3MWalletInfo>> itemList;
  final Function(W3MWalletInfo walletInfo)? onTapWallet;
  final bool isPaginating;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final List<Widget> children = itemList
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
        .toList();

    if (isPaginating) {
      final isLandscape = !ResponsiveData.isPortrait(context);
      final loadingList = [
        const WalletGridItem(title: ''),
        const WalletGridItem(title: ''),
        const WalletGridItem(title: ''),
        const WalletGridItem(title: ''),
      ]
          .map(
            (e) => SizedBox(
              width: ResponsiveData.gridItemSzieOf(context).width,
              height: ResponsiveData.gridItemSzieOf(context).height,
              child: Shimmer.fromColors(
                baseColor: themeColors.grayGlass100,
                highlightColor: themeColors.grayGlass025,
                child: const WalletGridItem(title: ''),
              ),
            ),
          )
          .toList();
      children.addAll(loadingList);
      if (isLandscape) {
        children.addAll(loadingList);
      }
    }

    return Container(
      padding: const EdgeInsets.only(bottom: kPadding12),
      child: Wrap(
        spacing: kGridAxisSpacing,
        runSpacing: kGridAxisSpacing,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: children,
      ),
    );
  }
}
