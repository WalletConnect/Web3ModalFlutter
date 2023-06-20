import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/web3modal_theme.dart';

class Web3ModalNavBar extends StatelessWidget {
  const Web3ModalNavBar({
    Key? key,
    required this.title,
    this.onBack,
    this.actionWidget,
    required this.child,
  }) : super(key: key);

  final Widget title;
  final VoidCallback? onBack;
  final Widget? actionWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 60,
                child: Row(
                  children: [
                    if (onBack != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Web3ModalTheme.of(context).backgroundColor,
                        onPressed: onBack,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: title,
              ),
              SizedBox(
                width: 60,
                child: Row(
                  children: [
                    if (actionWidget != null) actionWidget!,
                  ],
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
