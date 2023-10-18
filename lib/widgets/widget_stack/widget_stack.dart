import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:web3modal_flutter/pages/wallets_list_short_page.dart';
import 'package:web3modal_flutter/widgets/widget_stack/i_widget_stack.dart';
//
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';

class WidgetStack extends IWidgetStack {
  final List<Widget> _stack = [];

  @override
  final ValueListenable<Widget> current = ValueNotifier<Widget>(
    const SizedBox.shrink(),
  );

  @override
  Widget getCurrent() {
    return _stack.last;
  }

  @override
  void add(Widget widget) {
    _stack.add(widget);

    notifyListeners();
  }

  @override
  void pop() {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
      notifyListeners();
    } else {
      throw Exception('The stack is empty. No widget to pop.');
    }
  }

  @override
  bool canPop() {
    return _stack.length > 1;
  }

  @override
  void popUntil(Key key) {
    if (_stack.isEmpty) {
      throw Exception('The stack is empty. No widget to pop.');
    } else {
      while (_stack.isNotEmpty && _stack.last.key != key) {
        _stack.removeLast();
      }
      notifyListeners();

      // Check if the stack is empty or the widget type not found
      if (_stack.isEmpty) {
        throw Exception('No widget of specified type found.');
      }
    }
  }

  @override
  bool containsKey(Key key) {
    return _stack.any((element) => element.key == key);
  }

  @override
  void clear() {
    _stack.clear();
    notifyListeners();
  }

  @override
  void addDefault() {
    final pType = platformUtils.instance.getPlatformType();

    // Choose the state based on platform
    if (pType == PlatformType.mobile) {
      add(const WalletsListShortPage());
    } else if (pType == PlatformType.desktop || pType == PlatformType.web) {
      // add(const QRCodeAndWalletListPage());
      // TODO fix non mobile page
    }
  }
}
