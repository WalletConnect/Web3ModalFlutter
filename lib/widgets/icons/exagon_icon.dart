import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class ExagonIcon extends StatelessWidget {
  const ExagonIcon({
    super.key,
    required this.assetPath,
    this.imageUrl,
    this.assetColor,
    this.circleColor,
    this.borderColor,
    this.size = 36.0,
    this.padding = 8.0,
  });
  final String assetPath;
  final String? imageUrl;
  final Color? assetColor, circleColor, borderColor;
  final double size, padding;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        shape: StarBorder.polygon(
          side: BorderSide(
            color: borderColor ?? themeData.colors.overgray005,
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          pointRounding: 0.3,
          sides: 6,
        ),
        color: circleColor ?? themeData.colors.overgray015,
      ),
      clipBehavior: Clip.hardEdge,
      child: (imageUrl != null)
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
            )
          : Padding(
              padding: EdgeInsets.all(padding),
              child: SvgPicture.asset(
                colorFilter: ColorFilter.mode(
                  assetColor ?? themeData.colors.foreground200,
                  BlendMode.srcIn,
                ),
                assetPath,
                package: 'web3modal_flutter',
                width: size,
                height: size,
              ),
            ),
    );
  }
}
