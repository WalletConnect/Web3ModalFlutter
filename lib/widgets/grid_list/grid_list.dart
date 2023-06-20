import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_provider.dart';
import 'package:web3modal_flutter/widgets/wallet_image.dart';

enum GridListState { short, long, extraShort }

class GridList<T> extends StatelessWidget {
  static const double tileSize = 60;
  static double getTileBorderRadius(double tileSize) => tileSize / 4.0;

  const GridList({
    super.key,
    this.state = GridListState.short,
    required this.provider,
    required this.viewLongList,
    required this.onSelect,
  });

  final GridListState state;
  final GridListProvider<T> provider;
  final void Function() viewLongList;
  final void Function(T) onSelect;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: provider.itemList,
      builder: (context, List<GridListItemModel<T>> value, child) {
        if (value.isEmpty) {
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
            itemCount = min(8, value.length);
            height = 240;
            break;
          case GridListState.long:
            itemCount = value.length;
            height = 600;
            break;
          case GridListState.extraShort:
            itemCount = min(4, value.length);
            height = 120;
            break;
        }

        return Container(
          padding: const EdgeInsets.all(8.0),
          height: height,
          child: GridView.builder(
            key: Key('${value.length}'),
            itemCount: itemCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              if (index == itemCount - 1 &&
                  value.length > itemCount &&
                  state != GridListState.long) {
                return _buildViewAll(
                  context,
                  value,
                  itemCount,
                );
              } else {
                return GridListItem(
                  key: Key(value[index].title),
                  title: value[index].title,
                  description: value[index].description,
                  onSelect: () => onSelect(value[index].data),
                  child: WalletImage(
                    imageUrl: value[index].image,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildViewAll(
    BuildContext context,
    List<GridListItemModel<T>> items,
    int startIndex,
  ) {
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
        width: GridList.tileSize,
        height: GridList.tileSize,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              GridList.getTileBorderRadius(GridList.tileSize),
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
