import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item_model.dart';

abstract class GridListProvider<T> {
  abstract ValueNotifier<List<GridListItemModel<T>>> itemList;
  abstract ValueNotifier<bool> initialized;

  void filterList({
    String? query,
  });
}
