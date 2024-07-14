import 'dart:math';

import 'package:flutter/material.dart';

import 'package:web3modal_flutter/pages/about_wallets.dart';
import 'package:web3modal_flutter/pages/confirm_email_page.dart';
import 'package:web3modal_flutter/pages/connect_wallet_page.dart';
import 'package:web3modal_flutter/pages/qr_code_page.dart';
import 'package:web3modal_flutter/services/analytics_service/analytics_service_singleton.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/models/email_login_step.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/input_email.dart';
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
  void initState() {
    super.initState();
    magicService.instance.isEnabled.addListener(_mailEnabledListener);
  }

  void _mailEnabledListener() {
    setState(() {});
  }

  @override
  void dispose() {
    magicService.instance.isEnabled.removeListener(_mailEnabledListener);
    super.dispose();
  }

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
          widgetStack.instance.push(
            const AboutWallets(),
            event: ClickWalletHelpEvent(),
          );
        },
      ),
      safeAreaLeft: true,
      safeAreaRight: true,
      body: ExplorerServiceItemsListener(
        builder: (context, initialised, items, _) {
          if (!initialised) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: const WalletsList(
                isLoading: true,
                itemList: [],
              ),
            );
          }
          final itemsCount = min(kShortWalletListCount, items.length);
          if (itemsCount < kShortWalletListCount) {
            maxHeight = kListItemHeight * (itemsCount + 1.5);
          }
          final emailEnabled = magicService.instance.isEnabled.value;
          if (emailEnabled) {
            maxHeight += (kSearchFieldHeight * 2);
          }
          final itemsToShow = items.getRange(0, itemsCount);
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: WalletsList(
              onTapWallet: (data) {
                service.selectWallet(data);
                widgetStack.instance.push(const ConnectWalletPage());
              },
              firstItem: _EmailLoginWidget(),
              itemList: itemsToShow.toList(),
              bottomItems: [
                AllWalletsItem(
                  trailing: (items.length <= kShortWalletListCount)
                      ? null
                      : ValueListenableBuilder<int>(
                          valueListenable:
                              explorerService.instance.totalListings,
                          builder: (context, value, _) {
                            return WalletItemChip(value: value.lazyCount);
                          },
                        ),
                  onTap: () {
                    if (items.length <= kShortWalletListCount) {
                      widgetStack.instance.push(
                        const QRCodePage(),
                        event: SelectWalletEvent(
                          name: 'WalletConnect',
                          platform: AnalyticsPlatform.qrcode,
                        ),
                      );
                    } else {
                      widgetStack.instance.push(
                        const WalletsListLongPage(),
                        event: ClickAllWalletsEvent(),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
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

class _EmailLoginWidget extends StatefulWidget {
  @override
  State<_EmailLoginWidget> createState() => __EmailLoginWidgetState();
}

class __EmailLoginWidgetState extends State<_EmailLoginWidget> {
  bool _submitted = false;
  @override
  void initState() {
    super.initState();
    magicService.instance.step.addListener(_stepListener);
  }

  void _stepListener() {
    debugPrint(magicService.instance.step.value.toString());
    if ((magicService.instance.step.value == EmailLoginStep.verifyDevice ||
            magicService.instance.step.value == EmailLoginStep.verifyOtp ||
            magicService.instance.step.value == EmailLoginStep.verifyOtp2) &&
        _submitted) {
      widgetStack.instance.push(ConfirmEmailPage());
      _submitted = false;
    }
  }

  @override
  void dispose() {
    magicService.instance.step.removeListener(_stepListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: magicService.instance.isEnabled,
      builder: (context, emailEnabled, _) {
        if (!emailEnabled) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            InputEmailWidget(
              onFocus: (value) {
                if (value) {
                  analyticsService.instance.sendEvent(
                    EmailLoginSelected(),
                  );
                }
              },
              onValueChange: (value) {
                magicService.instance.setEmail(value);
              },
              onSubmitted: (value) {
                setState(() => _submitted = true);
                final service = Web3ModalProvider.of(context).service;
                final chainId = service.selectedChain?.chainId;
                analyticsService.instance.sendEvent(EmailSubmitted());
                magicService.instance.connectEmail(
                  value: value,
                  chainId: chainId,
                );
              },
            ),
            const SizedBox.square(dimension: 4.0),
            _LoginDivider(),
            const SizedBox.square(dimension: kListViewSeparatorHeight),
          ],
        );
      },
    );
  }
}
