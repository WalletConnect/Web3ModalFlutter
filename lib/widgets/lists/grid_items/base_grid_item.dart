import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/theme.dart';

class BaseGridItem extends StatelessWidget {
  const BaseGridItem({
    super.key,
    this.bottom,
    this.onTap,
    this.isSelected = false,
    required this.child,
  });
  final Widget? bottom;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return FilledButton(
      onPressed: onTap,
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size>(
          const Size(1000.0, kGridItemHeight),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          isSelected
              ? themeData.colors.overblue020
              : themeData.colors.overgray002,
        ),
        overlayColor: MaterialStateProperty.all<Color>(
          isSelected
              ? themeData.colors.overblue020
              : themeData.colors.overgray005,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusXS),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.all(0.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
