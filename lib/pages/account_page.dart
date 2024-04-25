import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/pages/edit_email_page.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/pages/upgrade_wallet_page.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/widgets/loader.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_orb.dart';
import 'package:web3modal_flutter/widgets/buttons/address_copy_button.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/account_list_item.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';
import 'package:web3modal_flutter/widgets/text/w3m_balance.dart';

class AccountPage extends StatefulWidget {
  const AccountPage() : super(key: KeyConstants.accountPage);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  IW3MService? _service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service = Web3ModalProvider.of(context).service;
      _service?.addListener(_rebuild);
      _rebuild();
    });
  }

  void _rebuild() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rebuild();
    }
  }

  @override
  void dispose() {
    _service?.removeListener(_rebuild);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
      return ContentLoading(viewHeight: 400.0);
    }
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: kNavbarHeight / 2,
              left: kPadding12,
              right: kPadding12,
              bottom: kPadding12,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const W3MAccountOrb(size: 72.0),
                      const SizedBox.square(dimension: kPadding12),
                      const W3MAddressWithCopyButton(),
                      const W3MBalanceText(),
                      Visibility(
                        visible: _service!.selectedChain?.blockExplorer != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: kPadding12),
                          child: SimpleIconButton(
                            onTap: () => _service!.launchBlockExplorer(),
                            leftIcon: 'assets/icons/compass.svg',
                            rightIcon: 'assets/icons/arrow_top_right.svg',
                            title: 'Block Explorer',
                            backgroundColor: themeColors.background125,
                            foregroundColor: themeColors.foreground150,
                            overlayColor: MaterialStateProperty.all<Color>(
                              themeColors.background200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox.square(dimension: kPadding12),
                  Visibility(
                    visible: _service!.session?.sessionService.isMagic ?? false,
                    child: Column(
                      children: [
                        const SizedBox.square(dimension: kPadding8),
                        AccountListItem(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kPadding8,
                            vertical: kPadding12,
                          ),
                          iconWidget: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: RoundedIcon(
                              borderRadius: radiuses.isSquare()
                                  ? 0.0
                                  : radiuses.isCircular()
                                      ? 40.0
                                      : 8.0,
                              size: 40.0,
                              assetPath: 'assets/icons/regular/wallet.svg',
                              assetColor: themeColors.accent100,
                              circleColor: themeColors.accenGlass010,
                              borderColor: themeColors.accenGlass010,
                            ),
                          ),
                          title: 'Upgrade your wallet',
                          subtitle: 'Transition to a self-custodial wallet',
                          hightlighted: true,
                          flexible: true,
                          titleStyle:
                              themeData.textStyles.paragraph500.copyWith(
                            color: themeColors.foreground100,
                          ),
                          onTap: () =>
                              widgetStack.instance.push(UpgradeWalletPage()),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _service!.session?.sessionService.isMagic ?? false,
                    child: Column(
                      children: [
                        const SizedBox.square(dimension: kPadding8),
                        AccountListItem(
                          iconPath: 'assets/icons/mail.svg',
                          iconColor: themeColors.foreground100,
                          title: _service!.session?.email ?? '',
                          titleStyle:
                              themeData.textStyles.paragraph500.copyWith(
                            color: themeColors.foreground100,
                          ),
                          onTap: () {
                            widgetStack.instance.push(EditEmailPage());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox.square(dimension: kPadding8),
                  _SelectNetworkButton(),
                  const SizedBox.square(dimension: kPadding8),
                  AccountListItem(
                    iconPath: 'assets/icons/disconnect.svg',
                    trailing: _service!.status.isLoading
                        ? Row(
                            children: [
                              CircularLoader(size: 18.0, strokeWidth: 2.0),
                              SizedBox.square(dimension: kPadding12),
                            ],
                          )
                        : const SizedBox.shrink(),
                    title: 'Disconnect',
                    titleStyle: themeData.textStyles.paragraph500.copyWith(
                      color: themeColors.foreground200,
                    ),
                    onTap: _service!.status.isLoading
                        ? null
                        : () async {
                            await _service!.disconnect();
                            _service!.closeModal();
                          },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: NavbarActionButton(
              asset: 'assets/icons/close.svg',
              action: () => _service!.closeModal(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectNetworkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final chainId = service.selectedChain?.chainId ?? '';
    final imageId = AssetUtil.getChainIconId(chainId) ?? '';
    final tokenImage = explorerService.instance.getAssetImageUrl(imageId);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return AccountListItem(
      iconWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: imageId.isEmpty
            ? RoundedIcon(
                assetPath: 'assets/icons/network.svg',
                assetColor: themeColors.inverse100,
                borderRadius: radiuses.isSquare() ? 0.0 : null,
              )
            : RoundedIcon(
                borderRadius: radiuses.isSquare() ? 0.0 : null,
                imageUrl: tokenImage,
                assetColor: themeColors.background100,
              ),
      ),
      title: service.selectedChain?.chainName ?? '',
      titleStyle: themeData.textStyles.paragraph500.copyWith(
        color: themeColors.foreground100,
      ),
      onTap: () {
        widgetStack.instance.push(
          SelectNetworkPage(),
          event: ClickNetworksEvent(),
        );
      },
    );
  }
}
