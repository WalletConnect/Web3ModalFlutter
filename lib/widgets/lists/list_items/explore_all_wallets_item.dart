import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';

class ExploreAllWalletsItem extends StatelessWidget {
  const ExploreAllWalletsItem({
    super.key,
    required this.images,
    this.trailing,
    this.onTap,
  });
  final Widget? trailing;
  final List<String> images;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return WalletListItem(
      onTap: onTap,
      imageWidget: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            width: constraints.maxHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiuses.radius3XS),
              border: Border.all(
                color: themeColors.grayGlass010,
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              color: themeColors.grayGlass010,
            ),
            clipBehavior: Clip.antiAlias,
            child: Wrap(
              spacing: 2.0,
              runSpacing: 2.0,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: images
                  .map(
                    (e) => SizedBox(
                      width: (constraints.maxHeight / 2) - 4.0,
                      height: (constraints.maxHeight / 2) - 4.0,
                      child: W3MListAvatar(
                        borderRadius: radiuses.radius4XS,
                        imageUrl: e,
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
      title: 'Explore All',
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SvgPicture.asset(
          'assets/icons/arrow_top_right.svg',
          package: 'web3modal_flutter',
          colorFilter: ColorFilter.mode(
            themeColors.foreground200,
            BlendMode.srcIn,
          ),
          width: 18.0,
          height: 18.0,
        ),
      ),
    );
  }
}
