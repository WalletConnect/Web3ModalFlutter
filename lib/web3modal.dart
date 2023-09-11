import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';

import 'package:web3modal_flutter/pages/help_page.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';

import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/toast/walletconnect_modal_toast_manager.dart';
import 'package:walletconnect_modal_flutter/widgets/transition_container.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_icon_button.dart';

class Web3Modal extends StatefulWidget {
  const Web3Modal({super.key, this.startWidget});

  final Widget? startWidget;

  @override
  State<Web3Modal> createState() => _Web3ModalState();
}

class _Web3ModalState extends State<Web3Modal> {
  bool _initialized = false;
  Widget? _body;

  // final List<WalletConnectModalState> _stateStack = [];

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
    final BorderRadius outerContainerBorderRadius = bottomSheet
        ? const BorderRadius.only(
            topLeft: Radius.circular(
              kRadius3XS,
            ),
            topRight: Radius.circular(
              kRadius3XS,
            ),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(
              kRadius3XS,
            ),
            topRight: Radius.circular(
              kRadius3XS,
            ),
            bottomLeft: Radius.circular(
              kRadiusM,
            ),
            bottomRight: Radius.circular(
              kRadiusM,
            ),
          );

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

    final double width = bottomSheet ? double.infinity : 600;
    const double modalWidgetHeight = 30;

    return Container(
      decoration: BoxDecoration(
        color: themeData.colors.blue100,
        borderRadius: outerContainerBorderRadius,
      ),
      width: width,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/walletconnect_logo_full_white.svg',
                  height: modalWidgetHeight,
                  package: 'walletconnect_modal_flutter',
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: _body?.key == Web3ModalKeyConstants.helpPageKey
                            ? themeData.colors.inverse100
                            : themeData.colors.inverse000,
                        borderRadius: BorderRadius.circular(
                          modalWidgetHeight / 2,
                        ),
                      ),
                      height: modalWidgetHeight,
                      width: modalWidgetHeight,
                      child: WalletConnectIconButton(
                        key: Web3ModalKeyConstants.helpButtonKey,
                        iconPath: 'assets/icons/help.svg',
                        color: _body?.key == Web3ModalKeyConstants.helpPageKey
                            ? themeData.colors.inverse000
                            : themeData.colors.inverse100,
                        onPressed: () {
                          if (_body?.key == Web3ModalKeyConstants.helpPageKey) {
                            widgetStack.instance.pop();
                            return;
                          } else if (widgetStack.instance.containsKey(
                            Web3ModalKeyConstants.helpPageKey,
                          )) {
                            widgetStack.instance.popUntil(
                              Web3ModalKeyConstants.helpPageKey,
                            );
                          } else {
                            widgetStack.instance.add(
                              const HelpPage(),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: themeData.colors.inverse000,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      height: modalWidgetHeight,
                      width: modalWidgetHeight,
                      child: WalletConnectIconButton(
                        key: Web3ModalKeyConstants.closeModalButtonKey,
                        iconPath: 'assets/icons/close.svg',
                        color: themeData.colors.inverse100,
                        onPressed: () {
                          Web3ModalProvider.of(context).service.close();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: innerContainerBorderRadius,
              color: themeData.colors.background100,
            ),
            // padding: const EdgeInsets.only(
            //   bottom: 20,
            // ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_initialized || _body == null) {
      return Container(
        constraints: const BoxConstraints(
          // minWidth: 300,
          // maxWidth: 400,
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
