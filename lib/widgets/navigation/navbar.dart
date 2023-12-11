import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/constants.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';

class Web3ModalNavbar extends StatelessWidget {
  const Web3ModalNavbar({
    super.key,
    this.onBack,
    this.onTapTitle,
    required this.body,
    required this.title,
    this.leftAction,
    this.safeAreaLeft = false,
    this.safeAreaRight = false,
    this.safeAreaBottom = true,
  });

  final VoidCallback? onBack;
  final VoidCallback? onTapTitle;
  final Widget body;
  final String title;
  final NavbarActionButton? leftAction;
  final bool safeAreaLeft, safeAreaRight, safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(
          left: true,
          right: true,
          top: false,
          bottom: false,
          child: SizedBox(
            height: kNavbarHeight,
            child: ValueListenableBuilder(
              valueListenable: widgetStack.instance.onRenderScreen,
              builder: (context, render, _) {
                if (!render) return SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetStack.instance.canPop()
                        ? NavbarActionButton(
                            asset: 'assets/icons/chevron_left.svg',
                            action: onBack ?? widgetStack.instance.pop,
                          )
                        : (leftAction ??
                            const SizedBox.square(dimension: kNavbarHeight)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTapTitle?.call(),
                        child: Center(
                          child: Text(
                            title,
                            style: themeData.textStyles.paragraph600.copyWith(
                              color: themeColors.foreground100,
                            ),
                          ),
                        ),
                      ),
                    ),
                    NavbarActionButton(
                      asset: 'assets/icons/close.svg',
                      action: () {
                        Web3ModalProvider.of(context).service.closeModal();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Divider(color: themeColors.grayGlass005, height: 0.0),
        Flexible(
          child: SafeArea(
            left: safeAreaLeft,
            right: safeAreaRight,
            bottom: safeAreaBottom,
            child: body,
          ),
        ),
      ],
    );
  }
}
