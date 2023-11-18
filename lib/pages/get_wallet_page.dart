import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/all_wallets_item.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_list.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/explorer_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/utils/url/url_utils_singleton.dart';

class GetWalletPage extends StatelessWidget {
  const GetWalletPage() : super(key: Web3ModalKeyConstants.getAWalletPageKey);

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final isPortrait = ResponsiveData.isPortrait(context);
    final maxHeight = isPortrait
        ? (kListItemHeight * 7)
        : ResponsiveData.maxHeightOf(context);
    return Web3ModalNavbar(
      title: 'Get a Wallet',
      body: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ExplorerServiceItemsListener(
          builder: (context, initialised, items, _) {
            if (!initialised) {
              return const ContentLoading();
            }

            final notInstalledItems = items
                .where((GridItem<W3MWalletInfo> w) =>
                    !w.data.installed && !w.data.recent)
                .toList();
            final itemsToShow = notInstalledItems
                .getRange(0, min(5, notInstalledItems.length))
                .toList();

            return WalletsList(
              itemList: itemsToShow,
              onTapWallet: (data) {
                final url = Platform.isIOS
                    ? data.listing.appStore
                    : data.listing.playStore;
                if ((url ?? '').isNotEmpty) {
                  urlUtils.instance.launchUrl(
                    Uri.parse(url!),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              lastItem: AllWalletsItem(
                title: 'Explore all',
                onTap: () => urlUtils.instance.launchUrl(
                  Uri.parse(StringConstants.exploreAllWallets),
                  mode: LaunchMode.externalApplication,
                ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
