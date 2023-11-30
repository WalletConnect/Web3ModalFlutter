import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class WalletItemChip extends StatelessWidget {
  const WalletItemChip({
    super.key,
    required this.value,
    this.color,
    this.textStyle,
  });
  final String value;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return Container(
      decoration: BoxDecoration(
        color: color ?? themeColors.grayGlass010,
        borderRadius: BorderRadius.all(Radius.circular(radiuses.radius4XS)),
      ),
      padding: const EdgeInsets.all(5.0),
      margin: const EdgeInsets.only(right: 8.0),
      child: Text(
        value,
        style: textStyle ??
            themeData.textStyles.micro700.copyWith(
              color: themeColors.foreground150,
            ),
      ),
    );
  }
}
