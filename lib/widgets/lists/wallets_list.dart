import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';

import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';

class WalletsList extends StatelessWidget {
  const WalletsList({
    super.key,
    required this.itemList,
    this.firstItem,
    this.lastItem,
    this.onTapWallet,
    this.viewPortRows = kShortWalletListCount,
  });
  final List<GridListItemModel<WalletData>> itemList;
  final Widget? firstItem;
  final Widget? lastItem;
  final Function(WalletData)? onTapWallet;
  final int viewPortRows;

  double _listMaxHeight(BuildContext context) {
    return (kListItemHeight * viewPortRows) +
        (kListViewSeparatorHeight * viewPortRows) +
        kListViewSeparatorHeight +
        MediaQuery.of(context).padding.bottom;
  }

  @override
  Widget build(BuildContext context) {
    final walletsListItems = itemList.map(
      (e) => WalletListItem(
        onTap: () => onTapWallet?.call(e.data),
        imageUrl: e.image,
        title: e.title,
        trailing:
            e.data.recent ? const WalletItemChip(value: ' RECENT ') : null,
      ),
    );
    final List<Widget> items = List<Widget>.from(walletsListItems);
    if (firstItem != null) {
      items.insert(0, firstItem!);
    }
    if (lastItem != null) {
      items.add(lastItem!);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: _listMaxHeight(context)),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: kPadding16,
          vertical: kPadding12,
        ),
        itemBuilder: (context, index) => items[index],
        separatorBuilder: (_, __) => const SizedBox.square(
          dimension: kListViewSeparatorHeight,
        ),
        itemCount: items.length,
        physics: viewPortRows <= items.length
            ? const NeverScrollableScrollPhysics()
            : null,
      ),
    );
  }
}
