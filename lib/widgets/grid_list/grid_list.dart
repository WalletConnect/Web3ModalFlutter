import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/widgets/wallet_image.dart';
import 'package:web3modal_flutter/widgets/web3modal_theme.dart';

enum GridListState { short, long, extraShort }

class GridList extends StatelessWidget {
  static const double tileSize = 60;
  static double getTileBorderRadius(double tileSize) => tileSize / 4.0;

  const GridList({
    super.key,
    this.state = GridListState.short,
    required this.items,
    required this.viewLongList,
  });

  final GridListState state;
  final List<GridListItemModel> items;
  final void Function() viewLongList;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    int itemCount;
    double height;
    switch (state) {
      case GridListState.short:
        itemCount = 8;
        height = 240;
        break;
      case GridListState.long:
        itemCount = items.length;
        height = 600;
        break;
      case GridListState.extraShort:
        itemCount = 4;
        height = 120;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      height: height,
      child: GridView.builder(
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          if (index == itemCount - 1 &&
              items.length > itemCount &&
              state != GridListState.long) {
            return _buildViewAll(
              context,
              itemCount,
            );
          } else {
            return GridListItem(
              title: items[index].title,
              description: items[index].description,
              onSelect: items[index].onSelect,
              child: WalletImage(
                imageUrl: items[index].image,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildViewAll(BuildContext context, int startIndex) {
    List<Widget> images = [];

    for (int i = 0; i < 4; i++) {
      images.add(
        WalletImage(
          imageUrl: items[startIndex + i].image,
          imageSize: GridList.tileSize / 3.0,
        ),
      );

      if (i + 1 > items.length) {
        break;
      }
    }

    return GridListItem(
      title: 'View All',
      onSelect: viewLongList,
      child: Container(
        width: tileSize,
        height: tileSize,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              getTileBorderRadius(GridList.tileSize),
            ),
            border: Border.all(
              color: Colors.grey,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            color: Colors.grey.shade800),
        child: Center(
          child: Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: images,
          ),
        ),
      ),
    );
  }
}
