import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class W3MCirclePainter extends StatelessWidget {
  const W3MCirclePainter({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeData.colors.blue100,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
