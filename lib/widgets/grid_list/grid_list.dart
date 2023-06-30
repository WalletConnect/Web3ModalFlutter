import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_provider.dart';
import 'package:web3modal_flutter/widgets/wallet_image.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_theme.dart';

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
    final WalletConnectModalTheme theme = WalletConnectModalTheme.of(context);

    return ValueListenableBuilder(
      valueListenable: provider.initialized,
      builder: (context, bool value, child) {
        if (value) {
          return _buildGridList(context);
        } else {
          return Container(
            padding: const EdgeInsets.all(8.0),
            height: 240,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: theme.data.primary100,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildGridList(BuildContext context) {
    final WalletConnectModalTheme theme = WalletConnectModalTheme.of(context);

    return ValueListenableBuilder(
      valueListenable: provider.itemList,
      builder: (context, List<GridListItemModel<T>> value, child) {
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

        if (value.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No items found.',
                style: TextStyle(
                  color: theme.data.foreground200,
                  fontFamily: theme.data.fontFamily,
                  fontSize: 16,
                ),
              ),
            ),
          );
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
    final WalletConnectModalTheme theme = WalletConnectModalTheme.of(context);

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
          color: theme.data.background200,
          border: Border.all(
            color: theme.data.overlay010,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(
            GridList.getTileBorderRadius(GridList.tileSize),
          ),
        ),
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
