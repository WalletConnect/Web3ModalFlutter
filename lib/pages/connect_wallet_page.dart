import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/avatars/wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/download_wallet_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item_simple.dart';
import 'package:web3modal_flutter/widgets/loading_border.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

import 'package:walletconnect_modal_flutter/services/utils/toast/toast_message.dart';
import 'package:walletconnect_modal_flutter/services/utils/toast/toast_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';

class ConnectWalletPage extends StatefulWidget {
  const ConnectWalletPage()
      : super(key: Web3ModalKeyConstants.connecWalletPageKey);

  @override
  State<ConnectWalletPage> createState() => _ConnectWalletPageState();
}

class _ConnectWalletPageState extends State<ConnectWalletPage>
    with WidgetsBindingObserver {
  IW3MService? _service;
  WalletData? _selectedWallet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service = Web3ModalProvider.of(context).service;
      _selectedWallet = _service?.selectedWallet;
      if (_selectedWallet?.installed == true) {
        _service?.connectWallet(walletData: _selectedWallet!);
      }
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final isOpen = _service?.isOpen ?? false;
      if (isOpen && _service?.session != null) {
        _service?.close();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final themeData = Web3ModalTheme.getDataOf(context);
    final walletName = service.selectedWallet?.listing.name ?? 'Wallet';
    final imageId = service.selectedWallet?.listing.imageId ?? '';
    final imageUrl =
        explorerService.instance!.getWalletImageUrl(imageId: imageId);

    return Web3ModalNavbar(
      title: walletName,
      onBack: () {
        service.selectWallet(walletData: null);
        widgetStack.instance.pop();
      },
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox.square(dimension: 30.0),
            LoadingBorder(
              child: WalletAvatar(imageUrl: imageUrl),
            ),
            const SizedBox.square(dimension: 20.0),
            (_selectedWallet?.installed == true)
                ? Text(
                    'Continue in $walletName',
                    style: themeData.textStyles.paragraph500.copyWith(
                      color: themeData.colors.foreground100,
                    ),
                  )
                : Text(
                    'Not detected',
                    style: themeData.textStyles.paragraph500.copyWith(
                      color: themeData.colors.foreground100,
                    ),
                  ),
            const SizedBox.square(dimension: 8.0),
            (_selectedWallet?.installed == true)
                ? Text(
                    'Accept connection request in the wallet',
                    style: themeData.textStyles.small500.copyWith(
                      color: themeData.colors.foreground200,
                    ),
                  )
                : Text(
                    'Download and install $walletName to continue',
                    style: themeData.textStyles.small500.copyWith(
                      color: themeData.colors.foreground200,
                    ),
                  ),
            const SizedBox.square(dimension: 16.0),
            SimpleIconButton(
              onTap: () {
                service.connectWallet(walletData: service.selectedWallet!);
              },
              svgIcon: 'assets/icons/refresh.svg',
              title: 'Try again',
              backgroundColor: Colors.transparent,
              foregroundColor: themeData.colors.blue100,
            ),
            const SizedBox.square(dimension: 32.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: WalletListItemSimple(
                title: 'Copy link',
                icon: 'assets/icons/copy.svg',
                onTap: () => _copyToClipboard(context),
              ),
            ),
            if (_selectedWallet?.installed == false)
              Column(
                children: [
                  const SizedBox.square(dimension: 16.0),
                  Divider(
                    color: themeData.colors.overgray005,
                    height: 0.0,
                  ),
                  const SizedBox.square(dimension: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DownloadWalletItem(walletData: _selectedWallet!),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final service = Web3ModalProvider.of(context).service;
    await Clipboard.setData(ClipboardData(text: service.wcUri!));
    toastUtils.instance.show(
      ToastMessage(
        type: ToastType.info,
        text: 'Link copied',
      ),
    );
  }
}
