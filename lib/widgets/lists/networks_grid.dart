import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/grid_items/wallet_grid_item.dart';

import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';

class NetworksGrid extends StatelessWidget {
  const NetworksGrid({
    super.key,
    required this.itemList,
    this.onTapNetwork,
    this.viewPortRows = kShortWalletListCount,
  });
  final List<GridListItemModel<W3MChainInfo>> itemList;
  final Function(W3MChainInfo)? onTapNetwork;
  final int viewPortRows;

  double _gridMaxHeight(BuildContext context) {
    return (kGridItemHeight * viewPortRows) +
        ((kGridAxisSpacing * viewPortRows) * 2) +
        kPadding16 +
        MediaQuery.of(context).padding.bottom;
  }

  double _gridItemWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width -
            (kPadding16 * 2) -
            (kGridAxisSpacing * 6)) /
        kGridAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final rowsCount = (itemList.length / kGridAxisCount);
    final gridItemWidth = _gridItemWidth(context);
    final gridMaxHeight = _gridMaxHeight(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: gridMaxHeight),
      child: GridView.builder(
        physics: (rowsCount <= viewPortRows)
            ? const NeverScrollableScrollPhysics()
            : null,
        padding: EdgeInsets.only(
          left: kPadding16,
          right: kPadding16,
          top: kPadding16,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        itemCount: itemList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: kGridAxisCount,
          mainAxisSpacing: kGridAxisSpacing,
          crossAxisSpacing: kGridAxisSpacing,
          childAspectRatio: gridItemWidth / kGridItemHeight,
        ),
        itemBuilder: (context, index) {
          final info = itemList[index];
          return WalletGridItem(
            onTap: () => onTapNetwork?.call(info.data),
            isSelected: service.selectedChain?.chainId == info.id,
            imageUrl: info.image,
            title: info.title,
            isNetwork: true,
          );
        },
      ),
    );
  }
}
