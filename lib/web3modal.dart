import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';

import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/toast/walletconnect_modal_toast_manager.dart';
import 'package:walletconnect_modal_flutter/widgets/transition_container.dart';

class Web3Modal extends StatefulWidget {
  const Web3Modal({super.key, this.startWidget});

  final Widget? startWidget;

  @override
  State<Web3Modal> createState() => _Web3ModalState();
}

class _Web3ModalState extends State<Web3Modal> {
  bool _initialized = false;
  Widget? _body;

  @override
  void initState() {
    super.initState();
    widgetStack.instance.addListener(_widgetStackUpdated);

    if (widget.startWidget != null) {
      widgetStack.instance.add(widget.startWidget!);
    } else {
      widgetStack.instance.addDefault();
    }

    initialize();
  }

  @override
  void dispose() {
    widgetStack.instance.removeListener(_widgetStackUpdated);
    super.dispose();
  }

  Future<void> initialize() async {
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    final bool bottomSheet = platformUtils.instance.isBottomSheet();

    final BorderRadius innerContainerBorderRadius = bottomSheet
        ? const BorderRadius.only(
            topLeft: Radius.circular(
              kRadiusM,
            ),
            topRight: Radius.circular(
              kRadiusM,
            ),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(
              kRadiusM,
            ),
            topRight: Radius.circular(
              kRadiusM,
            ),
            bottomLeft: Radius.circular(
              kRadiusM,
            ),
            bottomRight: Radius.circular(
              kRadiusM,
            ),
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: innerContainerBorderRadius,
        color: themeData.colors.background100,
      ),
      child: Stack(
        children: [
          SafeArea(
            child: TransitionContainer(
              child: _buildBody(),
            ),
          ),
          const WalletConnectModalToastManager(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_initialized || _body == null) {
      return Container(
        constraints: const BoxConstraints(
          minHeight: 300,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircularProgressIndicator(
              color: Web3ModalTheme.getDataOf(context).colors.blue100,
            ),
          ),
        ),
      );
    }

    return _body!;
  }

  void _widgetStackUpdated() {
    setState(() {
      _body = widgetStack.instance.getCurrent();
    });
  }
}
