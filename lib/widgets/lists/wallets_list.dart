import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';

class WalletsList extends StatelessWidget {
  const WalletsList({
    super.key,
    required this.itemList,
    this.firstItem,
    this.lastItem,
    this.onTapWallet,
  });
  final List<GridListItemModel<WalletData>> itemList;
  final Widget? firstItem;
  final Widget? lastItem;
  final Function(WalletData)? onTapWallet;

  @override
  Widget build(BuildContext context) {
    debugPrint(itemList
        .asMap()
        .entries
        .map((e) => '${e.key} - ${e.value.data.listing.name}')
        .toList()
        .join('\n'));
    final List<Widget> items = [
      firstItem ?? const SizedBox.shrink(),
      ...(itemList.map(
        (e) => WalletListItem(
          onTap: () => onTapWallet?.call(e.data),
          image: Image.network(e.image),
          title: e.title,
          trailing:
              e.data.recent ? const WalletItemChip(value: ' RECENT ') : null,
        ),
      )).toList(),
      lastItem ?? const SizedBox.shrink(),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: (kListItemHeight * kItemsCount) + (8 * kItemsCount) + 12,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemBuilder: (context, index) => items[index],
        separatorBuilder: (_, __) => const SizedBox.square(dimension: 8.0),
        itemCount: items.length,
      ),
    );
  }
}
