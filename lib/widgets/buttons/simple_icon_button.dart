import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';

class SimpleIconButton extends StatelessWidget {
  const SimpleIconButton({
    super.key,
    required this.onTap,
    required this.title,
    this.leftIcon,
    this.rightIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.size = BaseButtonSize.regular,
    this.overlayColor,
    this.withBorder = true,
  });
  final VoidCallback? onTap;
  final String title;
  final String? leftIcon, rightIcon;
  final Color? backgroundColor, foregroundColor;
  final BaseButtonSize size;
  final MaterialStateProperty<Color>? overlayColor;
  final bool withBorder;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final borderRadius =
        radiuses.isSquare() ? 0.0 : (BaseButtonSize.regular.height / 2);
    return BaseButton(
      onTap: onTap,
      size: size,
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          backgroundColor ?? themeColors.accent100,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          foregroundColor ?? themeColors.inverse100,
        ),
        overlayColor: overlayColor,
        shape: withBorder
            ? MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
                (states) {
                  return RoundedRectangleBorder(
                    side: BorderSide(
                      color: themeColors.grayGlass010,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                  );
                },
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIcon != null)
            Row(
              children: [
                SvgPicture.asset(
                  leftIcon!,
                  package: 'web3modal_flutter',
                  colorFilter: ColorFilter.mode(
                    foregroundColor ?? themeColors.inverse100,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox.square(dimension: 8.0),
              ],
            ),
          Text(title),
          if (rightIcon != null)
            Row(
              children: [
                const SizedBox.square(dimension: 8.0),
                SvgPicture.asset(
                  rightIcon!,
                  package: 'web3modal_flutter',
                  colorFilter: ColorFilter.mode(
                    foregroundColor ?? themeColors.inverse100,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
