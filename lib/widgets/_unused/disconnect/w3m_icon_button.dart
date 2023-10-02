import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class W3MIconButton extends StatelessWidget {
  const W3MIconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final Widget icon;
  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return MaterialButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusColor: themeColors.grayGlass025,
      hoverColor: themeColors.grayGlass020,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 4),
              Text(
                text,
                style: themeData.textStyles.tiny500.copyWith(
                  color: themeColors.accent100,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
