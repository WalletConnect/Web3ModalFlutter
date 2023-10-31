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
    this.scrollController,
  });
  final List<GridItem<W3MWalletInfo>> itemList;
  final Function(W3MWalletInfo walletInfo)? onTapWallet;
  final bool isPaginating;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final List<Widget> children = itemList
        .map(
          (info) => SizedBox(
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

    final itemSize = ResponsiveData.gridItemSzieOf(context);
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        bottom: kPadding12 + ResponsiveData.paddingBottomOf(context),
        left: kPadding6,
        right: kPadding6,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveData.gridAxisCountOf(context),
        mainAxisSpacing: kPadding12,
        crossAxisSpacing: 0.0,
        mainAxisExtent: itemSize.height,
      ),
      itemBuilder: (_, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: itemSize.width,
              height: itemSize.height,
              child: children[index],
            ),
          ],
        );
      },
      itemCount: children.length,
    );
  }
}
