import 'dart:math';

import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/toast/walletconnect_modal_toast_manager.dart';
import 'package:web3modal_flutter/widgets/widget_stack/transition_container.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';

class Web3Modal extends StatefulWidget {
  const Web3Modal({super.key, this.startWidget});

  final Widget? startWidget;

  @override
  State<Web3Modal> createState() => _Web3ModalState();
}

class _Web3ModalState extends State<Web3Modal> {
  bool _initialized = false;
  Widget? _currentScreen;

  @override
  void initState() {
    super.initState();
    widgetStack.instance.addListener(_widgetStackUpdated);

    if (widget.startWidget != null) {
      widgetStack.instance.push(widget.startWidget!, renderScreen: true);
    } else {
      widgetStack.instance.addDefault();
    }

    _initialize();
  }

  @override
  void dispose() {
    widgetStack.instance.removeListener(_widgetStackUpdated);
    super.dispose();
  }

  void _initialize() => setState(() => _initialized = true);

  void _widgetStackUpdated() => setState(() {
        _currentScreen = widgetStack.instance.getCurrent();
      });

  bool get _isLoading => !_initialized || _currentScreen == null;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final bool bottomSheet = platformUtils.instance.isBottomSheet();
    final maxRadius = min(radiuses.radiusM, 36.0);
    final BorderRadius innerContainerBorderRadius = bottomSheet
        ? BorderRadius.only(
            topLeft: Radius.circular(maxRadius),
            topRight: Radius.circular(maxRadius),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(maxRadius),
            topRight: Radius.circular(maxRadius),
            bottomLeft: Radius.circular(maxRadius),
            bottomRight: Radius.circular(maxRadius),
          );

    return ResponsiveContainer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: innerContainerBorderRadius,
          border: Border.all(
            color: themeColors.grayGlass005,
            width: 1,
          ),
          color: themeColors.background125,
        ),
        child: Stack(
          children: [
            TransitionContainer(
              child: _isLoading ? const ContentLoading() : _currentScreen!,
            ),
            const WalletConnectModalToastManager(),
          ],
        ),
      ),
    );
  }
}
