import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web3modal_flutter/pages/about_wallets.dart';
import 'package:web3modal_flutter/pages/confirm_email_page.dart';
import 'package:web3modal_flutter/pages/connect_wallet_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/searchbar.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/pages/wallets_list_long_page.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/all_wallets_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_list.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/explorer_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class WalletsListShortPage extends StatefulWidget {
  const WalletsListShortPage()
      : super(key: KeyConstants.walletListShortPageKey);

  @override
  State<WalletsListShortPage> createState() => _WalletsListShortPageState();
}

class _WalletsListShortPageState extends State<WalletsListShortPage> {
  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final isPortrait = ResponsiveData.isPortrait(context);
    double maxHeight = isPortrait
        ? (kListItemHeight * 6)
        : ResponsiveData.maxHeightOf(context);
    return Web3ModalNavbar(
      title: 'Connect wallet',
      leftAction: NavbarActionButton(
        asset: 'assets/icons/help.svg',
        action: () {
          widgetStack.instance.push(const AboutWallets());
        },
      ),
      safeAreaLeft: true,
      safeAreaRight: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: kPadding12,
              top: kPadding8,
              bottom: kPadding8,
              right: kPadding12,
            ),
            child: InputEmailWidget(),
          ),
          _LoginDivider(),
          ExplorerServiceItemsListener(
            builder: (context, initialised, items, _) {
              if (!initialised || items.isEmpty) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: const WalletsList(
                    isLoading: true,
                    itemList: [],
                  ),
                );
              }
              final itemsCount = min(kShortWalletListCount, items.length);
              final itemsToShow = items.getRange(0, itemsCount);
              if (itemsCount < kShortWalletListCount && isPortrait) {
                maxHeight = kListItemHeight * (itemsCount + 1);
              }
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: WalletsList(
                  onTapWallet: (data) {
                    service.selectWallet(data);
                    widgetStack.instance.push(const ConnectWalletPage());
                  },
                  itemList: itemsToShow.toList(),
                  bottomItems: (itemsCount < kShortWalletListCount)
                      ? []
                      : [
                          AllWalletsItem(
                            trailing: ValueListenableBuilder<int>(
                              valueListenable:
                                  explorerService.instance.totalListings,
                              builder: (context, value, _) {
                                return WalletItemChip(value: value.lazyCount);
                              },
                            ),
                            onTap: () {
                              widgetStack.instance
                                  .push(const WalletsListLongPage());
                            },
                          ),
                        ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class InputEmailWidget extends StatefulWidget {
  const InputEmailWidget({super.key});

  @override
  State<InputEmailWidget> createState() => _InputEmailWidgetState();
}

class _InputEmailWidgetState extends State<InputEmailWidget> {
  bool hasFocus = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Web3ModalSearchBar(
      controller: _controller,
      // enabled: magicService.instance.initialized,
      hint: 'Email',
      iconPath: 'assets/icons/mail.svg',
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.go,
      onSubmitted: _connectEmail,
      debounce: false,
      onTextChanged: magicService.instance.setEmail,
      onFocusChange: (focus) => setState(() => hasFocus = focus),
      suffixIcon: ValueListenableBuilder<String>(
        valueListenable: magicService.instance.email,
        builder: (context, value, _) {
          if (!hasFocus) {
            return SizedBox.shrink();
          }
          if (value.isEmpty || !coreUtils.instance.isValidEmail(value)) {
            return GestureDetector(
              onTap: _clearEmail,
              child: Padding(
                padding: const EdgeInsets.all(kPadding8),
                child: SvgPicture.asset(
                  AssetUtil.getThemedAsset(context, 'input_cancel.svg'),
                  package: 'web3modal_flutter',
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: () => _connectEmail(value),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                'assets/icons/chevron_right.svg',
                package: 'web3modal_flutter',
                colorFilter: ColorFilter.mode(
                  themeColors.foreground300,
                  BlendMode.srcIn,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _connectEmail(String value) {
    if (value.isEmpty || !coreUtils.instance.isValidEmail(value)) {
      return;
    }
    magicService.instance.connectEmail(email: value);
    widgetStack.instance.push(ConfirmEmailPage());
  }

  void _clearEmail() {
    _controller.clear();
    magicService.instance.setEmail('');
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class _LoginDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final themeData = Web3ModalTheme.getDataOf(context);
    return Row(
      children: [
        Expanded(
          child: Divider(color: themeColors.grayGlass005, height: 0.0),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: kPadding12,
            right: kPadding12,
          ),
          child: Text(
            'Or',
            style: themeData.textStyles.small400.copyWith(
              color: themeColors.foreground200,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: themeColors.grayGlass005, height: 0.0),
        ),
      ],
    );
  }
}

extension on int {
  String get lazyCount {
    if (this <= 10) return toString();
    return '${toString().substring(0, toString().length - 1)}0+';
  }
}
