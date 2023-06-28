import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/web3modal_theme.dart';

class Web3ModalButton extends StatelessWidget {
  final Widget child;
  final void Function() onPressed;

  const Web3ModalButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Web3ModalTheme theme = Web3ModalTheme.of(context);

    return MaterialButton(
      onPressed: onPressed,
      color: theme.data.primary100,
      focusColor: theme.data.primary090,
      hoverColor: theme.data.primary090,
      highlightColor: theme.data.primary080,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          theme.data.radius4XS,
        ),
      ),
      child: child,
    );
  }
}
