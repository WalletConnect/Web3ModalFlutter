import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/lists/grid_items/wallet_grid_item.dart';

class NetworksGrid extends StatelessWidget {
  const NetworksGrid({
    super.key,
    required this.itemList,
    this.onTapNetwork,
  });
  final List<GridItem<W3MChainInfo>> itemList;
  final Function(W3MChainInfo)? onTapNetwork;

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final itemSize = ResponsiveData.gridItemSzieOf(context);
    final children = itemList
        .map(
          (info) => WalletGridItem(
            onTap: info.disabled ? null : () => onTapNetwork?.call(info.data),
            isSelected: service.selectedChain?.chainId == info.id,
            imageUrl: info.image,
            title: info.title,
            isNetwork: true,
          ),
        )
        .toList();
    return GridView.builder(
      padding: EdgeInsets.only(
        bottom: kPadding12 + ResponsiveData.paddingBottomOf(context),
        left: kPadding6,
        right: kPadding6,
        top: ResponsiveData.isPortrait(context) ? kPadding12 : kPadding6,
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
