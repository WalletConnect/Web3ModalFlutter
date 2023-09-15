import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';

class SimpleIconButton extends StatelessWidget {
  const SimpleIconButton({
    super.key,
    required this.onTap,
    required this.svgIcon,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
  });
  final VoidCallback? onTap;
  final String svgIcon, title;
  final Color? backgroundColor, foregroundColor;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return BaseButton(
      onTap: onTap,
      size: BaseButtonSize.regular,
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          backgroundColor ?? themeData.colors.blue100,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          foregroundColor ?? themeData.colors.inverse100,
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: BorderSide(
                color: themeData.colors.overgray010,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(
                BaseButtonSize.regular.height / 2,
              ),
            );
          },
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgIcon,
            package: 'web3modal_flutter',
            colorFilter: ColorFilter.mode(
              foregroundColor ?? themeData.colors.inverse100,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox.square(dimension: 8.0),
          Text(title),
        ],
      ),
    );
  }
}
