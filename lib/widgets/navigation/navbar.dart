import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';

class Web3ModalNavbar extends StatelessWidget {
  const Web3ModalNavbar({
    Key? key,
    this.onBack,
    required this.child,
    required this.title,
    this.leftAction,
  }) : super(key: key);

  final VoidCallback? onBack;
  final Widget child;
  final String title;
  final NavbarActionButton? leftAction;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: kNavbarHeight,
          child: Row(
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
                child: Center(
                  child: Text(
                    title,
                    style: themeData.textStyles.paragraph700.copyWith(
                      color: themeData.colors.foreground100,
                    ),
                  ),
                ),
              ),
              NavbarActionButton(
                asset: 'assets/icons/close.svg',
                action: () {
                  Web3ModalProvider.of(context).service.close();
                },
              ),
            ],
          ),
        ),
        Divider(
          color: themeData.colors.overgray005,
          height: 0.0,
        ),
        child,
      ],
    );
  }
}
