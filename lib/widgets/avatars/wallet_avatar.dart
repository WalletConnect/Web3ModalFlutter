import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/theme.dart';

class WalletAvatar extends StatelessWidget {
  const WalletAvatar({
    super.key,
    required this.imageUrl,
    this.borderRadius = kRadiusM,
  });
  final String imageUrl;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: themeData.colors.overgray010,
          width: 1.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(imageUrl),
    );
  }
}
