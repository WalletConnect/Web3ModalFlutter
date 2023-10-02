import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

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
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: isNetwork
          ? ShapeDecoration(
              shape: StarBorder.polygon(
                side: BorderSide(
                  color: color ?? themeColors.grayGlass010,
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
                color: color ?? themeColors.grayGlass010,
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(imageUrl),
    );
  }
}
