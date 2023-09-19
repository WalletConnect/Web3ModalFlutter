import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/theme.dart';

// TODO rename this to W3MWalletIcon
class W3MWalletAvatar extends StatelessWidget {
  const W3MWalletAvatar({
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
