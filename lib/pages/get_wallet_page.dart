import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/theme/theme.dart';

import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/url/url_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/constants/string_constants.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_button.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:walletconnect_modal_flutter/widgets/wallet_image.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';

class GetWalletPage extends StatelessWidget {
  const GetWalletPage() : super(key: Web3ModalKeyConstants.getAWalletPageKey);

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    bool longBottomSheet = platformUtils.instance.isLongBottomSheet(
      MediaQuery.of(context).orientation,
    );
    final int listCount = longBottomSheet ? 2 : 6;
    List<GridListItemModel<WalletData>> wallets = explorerService
        .instance!.itemList.value
        .where((GridListItemModel<WalletData> w) => !w.data.installed)
        .take(listCount)
        .toList();

    final List<Widget> walletWidgets = [];

    for (int i = 0; i < wallets.length; i++) {
      walletWidgets.add(
        WalletItem(wallet: wallets[i]),
      );
      if (i < wallets.length - 1) {
        walletWidgets.add(
          Divider(
            height: 0,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: themeData.colors.background300,
          ),
        );
      }
    }

    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'Get a wallet',
      ),
      child: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: walletWidgets,
          ),
          Divider(
            height: 0,
            thickness: 1,
            // indent: 20,
            // endIndent: 20,
            color: themeData.colors.background300,
          ),
          const SizedBox(height: 8.0),
          Text(
            "Not what you're looking for?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: themeData.colors.foreground100,
            ),
          ),
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            child: Text(
              "With hundreds of wallets out there, there's something for everyone",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: themeData.colors.foreground200,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          WalletConnectModalButton(
            onPressed: () => urlUtils.instance.launchUrl(
              Uri.parse(
                StringConstants.getAWalletExploreWalletsUrl,
              ),
              mode: LaunchMode.externalApplication,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 2.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore Wallets',
                  style: TextStyle(
                    fontFamily: themeData.textStyles.fontFamily,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.arrow_outward,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class WalletItem extends StatelessWidget {
  const WalletItem({
    super.key,
    required this.wallet,
  });

  final GridListItemModel<WalletData> wallet;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 200,
      ),
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
      ),
      child: ListTile(
        // dense: true,
        leading: WalletImage(
          imageUrl: wallet.image,
          imageSize: 40,
        ),
        title: Text(
          wallet.title,
          style: TextStyle(
            fontSize: 16.0,
            color: themeData.colors.foreground100,
          ),
        ),
        trailing: SizedBox(
          height: 28,
          width: 72,
          child: WalletConnectModalButton(
            onPressed: () => urlUtils.instance.launchUrl(
              Uri.parse(
                wallet.data.listing.homepage,
              ),
              mode: LaunchMode.externalApplication,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 0.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get',
                  style: TextStyle(
                    fontFamily: themeData.textStyles.fontFamily,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4.0),
                SvgPicture.asset(
                  'assets/icons/forward.svg',
                  width: 12,
                  height: 12,
                  package: 'walletconnect_modal_flutter',
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                // Icon(
                //   Icons.arrow_forward_ios,
                //   size: 12,
                //   color: themeData.inverse100,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
