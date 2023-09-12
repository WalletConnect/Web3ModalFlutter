import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web3modal_flutter/pages/help_page.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';

class Web3ModalNavbar extends StatelessWidget {
  const Web3ModalNavbar({
    Key? key,
    this.onBack,
    required this.child,
    required this.title,
  }) : super(key: key);

  final VoidCallback? onBack;
  final Widget child;
  final String title;

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
                  ? const BackNavAction()
                  : const HelpNavAction(),
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
              SizedBox.square(
                dimension: kNavbarHeight,
                child: IconButton(
                  onPressed: () {
                    Web3ModalProvider.of(context).service.close();
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/close.svg',
                    package: 'web3modal_flutter',
                    colorFilter: ColorFilter.mode(
                      themeData.colors.foreground100,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
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

class HelpNavAction extends StatelessWidget {
  const HelpNavAction({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return SizedBox.square(
      dimension: kNavbarHeight,
      child: IconButton(
        onPressed: () => widgetStack.instance.add(const HelpPage()),
        icon: SvgPicture.asset(
          'assets/icons/help.svg',
          package: 'web3modal_flutter',
          colorFilter: ColorFilter.mode(
            themeData.colors.foreground100,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class BackNavAction extends StatelessWidget {
  const BackNavAction({
    super.key,
    this.onBack,
  });
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final action = onBack ?? widgetStack.instance.pop;
    return SizedBox.square(
      dimension: kNavbarHeight,
      child: IconButton(
        onPressed: () => action.call(),
        icon: SvgPicture.asset(
          'assets/icons/chevron_left.svg',
          package: 'web3modal_flutter',
          colorFilter: ColorFilter.mode(
            themeData.colors.foreground100,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
