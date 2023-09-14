import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/theme.dart';

class NavbarActionButton extends StatelessWidget {
  const NavbarActionButton({
    super.key,
    required this.asset,
    required this.action,
  });
  final String asset;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return SizedBox.square(
      dimension: kNavbarHeight,
      child: IconButton(
        onPressed: action,
        icon: SvgPicture.asset(
          asset,
          package: 'web3modal_flutter',
          colorFilter: ColorFilter.mode(
            themeData.colors.foreground100,
            BlendMode.srcIn,
          ),
          width: 18.0,
          height: 18.0,
        ),
      ),
    );
  }
}
