import 'package:flutter/material.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';

class SecondaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const SecondaryButton({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return BaseButton(
      size: BaseButtonSize.regular,
      child: Text(title),
      onTap: onTap,
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) => themeColors.grayGlass001,
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) => themeColors.foreground200,
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: BorderSide(
                color: themeColors.grayGlass010,
                width: 1.0,
              ),
              borderRadius: radiuses.isSquare()
                  ? BorderRadius.all(Radius.zero)
                  : BorderRadius.circular(100.0),
            );
          },
        ),
      ),
    );
  }
}
