import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/web3modal_theme.dart';

class Web3ModalNavbarTitle extends StatelessWidget {
  const Web3ModalNavbarTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Web3ModalTheme.of(context).data.foreground100,
          ),
      textAlign: TextAlign.center,
    );
  }
}
