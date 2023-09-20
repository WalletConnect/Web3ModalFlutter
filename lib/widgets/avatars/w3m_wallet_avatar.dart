import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/theme.dart';

class W3MListAvatar extends StatelessWidget {
  const W3MListAvatar({
    super.key,
    required this.imageUrl,
    this.borderRadius = kRadiusM,
    this.isNetwork = false,
    this.color,
  });
  final String imageUrl;
  final double borderRadius;
  final bool isNetwork;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return Container(
      decoration: isNetwork
          ? ShapeDecoration(
              shape: StarBorder.polygon(
                side: BorderSide(
                  color: color ?? themeData.colors.overgray010,
                  width: 1.0,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                pointRounding: 0.3,
                sides: 6,
              ),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: color ?? themeData.colors.overgray010,
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(imageUrl),
    );
  }
}
