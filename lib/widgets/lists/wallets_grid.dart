import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/lists/grid_items/wallet_grid_item.dart';

import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';

class WalletsGrid extends StatelessWidget {
  const WalletsGrid({
    super.key,
    required this.itemList,
    this.onTapWallet,
    this.viewPortRows = kShortWalletListCount,
  });
  final List<GridListItemModel<WalletData>> itemList;
  final Function(WalletData)? onTapWallet;
  final int viewPortRows;

  double _gridMaxHeight(BuildContext context) {
    return (kGridItemHeight * viewPortRows) +
        ((kGridAxisSpacing * viewPortRows) * 2) +
        kPadding16 +
        (kNavbarHeight - kPadding16) +
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
    final themeData = Web3ModalTheme.getDataOf(context);
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
          top: kNavbarHeight,
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
            onTap: () => onTapWallet?.call(info.data),
            image: Image.network(info.image),
            title: info.title,
            bottom: info.data.recent
                ? Text(
                    'Recent',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: themeData.textStyles.micro600.copyWith(
                      color: themeData.colors.foreground200,
                      height: 1.0,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
