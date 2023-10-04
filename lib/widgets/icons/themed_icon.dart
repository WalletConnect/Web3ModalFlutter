import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class ThemedIcon extends StatelessWidget {
  const ThemedIcon({
    super.key,
    required this.iconPath,
    required this.size,
  });
  final String iconPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiuses.radius3XS),
        border: Border.all(
          color: themeColors.accenGlass020,
          width: 1.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        color: themeColors.accenGlass010,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            package: 'web3modal_flutter',
            colorFilter: ColorFilter.mode(
              themeColors.accent100,
              BlendMode.srcIn,
            ),
            height: size * 0.6,
            width: size * 0.6,
          ),
        ],
      ),
    );
  }
}
