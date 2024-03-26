import 'package:flutter/material.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const PrimaryButton({
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
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass010;
            }
            return themeColors.accent100;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeColors.foreground200;
            }
            return themeColors.inverse100;
          },
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
