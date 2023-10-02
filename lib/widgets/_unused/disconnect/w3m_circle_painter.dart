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
    final themeColors = Web3ModalTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeColors.accent100,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
