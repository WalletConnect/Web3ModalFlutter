import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/base_list_item.dart';

class WalletListItem extends StatelessWidget {
  const WalletListItem({
    super.key,
    required this.image,
    required this.title,
    this.trailing,
    this.onTap,
  });
  final Widget image;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return BaseListItem(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius3XS),
              border: Border.all(
                color: themeData.colors.overgray010,
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: image,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                title,
                style: themeData.textStyles.paragraph500.copyWith(
                  color: themeData.colors.foreground100,
                ),
              ),
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
