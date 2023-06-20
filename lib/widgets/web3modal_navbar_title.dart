import 'package:flutter/material.dart';

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
            color: Theme.of(context).colorScheme.onPrimary,
          ),
      textAlign: TextAlign.center,
    );
  }
}
