import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';

class WalletsList extends StatelessWidget {
  const WalletsList({
    super.key,
    required this.itemList,
    this.firstItem,
    this.lastItem,
    this.onTapWallet,
    this.isLoading = false,
  });
  final List<GridItem<W3MWalletInfo>> itemList;
  final Widget? firstItem;
  final Widget? lastItem;
  final Function(W3MWalletInfo walletInfo)? onTapWallet;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final loadingList = [
      const WalletListItem(title: ''),
      const WalletListItem(title: ''),
      const WalletListItem(title: ''),
      const WalletListItem(title: ''),
      const WalletListItem(title: ''),
    ].map(
      (e) => Shimmer.fromColors(
        baseColor: themeColors.grayGlass100,
        highlightColor: themeColors.grayGlass025,
        child: e,
      ),
    );

    final walletsListItems = isLoading
        ? loadingList
        : itemList.map(
            (e) => WalletListItem(
              onTap: () => onTapWallet?.call(e.data),
              imageUrl: e.image,
              title: e.title,
              trailing: e.data.recent
                  ? const WalletItemChip(value: ' RECENT ')
                  : null,
            ),
          );
    final List<Widget> items = List<Widget>.from(walletsListItems);
    if (firstItem != null) {
      items.insert(0, firstItem!);
    }
    if (lastItem != null) {
      items.add(lastItem!);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: kPadding12,
        vertical: kPadding12,
      ),
      itemBuilder: (context, index) {
        return SizedBox(
          height: kListItemHeight,
          width: 1000.0,
          child: items[index],
        );
      },
      separatorBuilder: (_, __) => const SizedBox.square(
        dimension: kListViewSeparatorHeight,
      ),
      itemCount: items.length,
    );
  }
}
