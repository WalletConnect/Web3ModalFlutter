import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class NavbarActionButton extends StatelessWidget {
  const NavbarActionButton({
    super.key,
    required this.asset,
    required this.action,
    this.color,
  });
  final String asset;
  final VoidCallback action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    return SizedBox.square(
      dimension: kNavbarHeight,
      child: IconButton(
        onPressed: action,
        icon: SvgPicture.asset(
          asset,
          package: 'web3modal_flutter',
          colorFilter: ColorFilter.mode(
            color ?? themeColors.foreground100,
            BlendMode.srcIn,
          ),
          width: 18.0,
          height: 18.0,
        ),
      ),
    );
  }
}
