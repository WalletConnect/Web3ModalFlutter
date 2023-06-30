import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web3modal_flutter/models/launch_url_exception.dart';
import 'package:web3modal_flutter/models/listings.dart';
import 'package:web3modal_flutter/pages/get_wallet_page.dart';
import 'package:web3modal_flutter/pages/help_page.dart';
import 'package:web3modal_flutter/services/toast/toast_message.dart';
import 'package:web3modal_flutter/services/toast/toast_service.dart';
import 'package:web3modal_flutter/services/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/services/utils/url/url_utils_singleton.dart';
import 'package:web3modal_flutter/utils/logger_util.dart';
import 'package:web3modal_flutter/widgets/qr_code_widget.dart';
import 'package:web3modal_flutter/services/walletconnect_modal/i_walletconnect_modal_service.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list.dart';
import 'package:web3modal_flutter/widgets/toast/web3modal_toast_manager.dart';
import 'package:web3modal_flutter/widgets/transition_container.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_navbar_title.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_search_bar.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_theme.dart';

class WalletConnectModal extends StatefulWidget {
  const WalletConnectModal({
    super.key,
    required this.service,
    required this.toastService,
    this.startState,
  });

  final IWalletConnectModalService service;
  final ToastService toastService;
  final WalletConnectModalState? startState;

  @override
  State<WalletConnectModal> createState() => _WalletConnectModalState();
}

class _WalletConnectModalState extends State<WalletConnectModal>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;

  final List<WalletConnectModalState> _stateStack = [];

  @override
  void initState() {
    super.initState();

    if (widget.startState != null) {
      _stateStack.add(widget.startState!);
    } else {
      final PlatformType pType = platformUtils.instance.getPlatformType();

      // Choose the state based on platform
      if (pType == PlatformType.mobile) {
        _stateStack.add(WalletConnectModalState.walletListShort);
      } else if (pType == PlatformType.desktop) {
        _stateStack.add(WalletConnectModalState.qrCodeAndWalletList);
      }
    }

    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalTheme theme = WalletConnectModalTheme.of(context);

    final BorderRadius containerBorderRadius =
        platformUtils.instance.isMobileWidth(
      MediaQuery.of(context).size.width,
    )
            ? BorderRadius.only(
                topLeft: Radius.circular(
                  theme.data.radius3XS,
                ),
                topRight: Radius.circular(
                  theme.data.radius3XS,
                ),
              )
            : BorderRadius.circular(
                theme.data.radius3XS,
              );

    return Container(
      // constraints: const BoxConstraints(
      //   minWidth: 200,
      //   maxWidth: 400,
      // ),
      decoration: BoxDecoration(
        color: theme.data.primary100,
        borderRadius: containerBorderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/walletconnect_logo_white.svg',
                      width: 20,
                      height: 20,
                      package: 'web3modal_flutter',
                      colorFilter: ColorFilter.mode(
                        theme.data.foreground100,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'WalletConnect',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: theme.data.foreground100,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: _stateStack.last == WalletConnectModalState.help
                          ? const Icon(Icons.help_outlined)
                          : const Icon(Icons.help_outline),
                      onPressed: () {
                        if (_stateStack
                            .contains(WalletConnectModalState.help)) {
                          _popUntil(WalletConnectModalState.help);
                        } else {
                          setState(() {
                            _stateStack.add(WalletConnectModalState.help);
                          });
                        }
                      },
                      color: theme.data.foreground100,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        widget.service.close();
                      },
                      color: theme.data.foreground100,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  theme.data.radius2XS,
                ),
                topRight: Radius.circular(
                  theme.data.radius2XS,
                ),
              ),
              color: theme.data.background100,
            ),
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            child: Stack(
              children: [
                TransitionContainer(
                  child: _buildBody(),
                ),
                Web3ModalToastManager(
                  toastService: widget.toastService,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_initialized) {
      return Container(
        constraints: const BoxConstraints(
          minWidth: 300,
          maxWidth: 400,
          minHeight: 300,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: WalletConnectModalTheme.of(context).data.primary100,
            ),
          ),
        ),
      );
    }

    switch (_stateStack.last) {
      case WalletConnectModalState.qrCode:
        return WalletConnectModalNavBar(
          key: Key(WalletConnectModalState.qrCode.name),
          title: const WalletConnectModalNavbarTitle(
            title: 'Scan QR Code',
          ),
          onBack: _pop,
          actionWidget: IconButton(
            icon: const Icon(Icons.copy_outlined),
            color: WalletConnectModalTheme.of(context).data.foreground100,
            onPressed: _copyQrCodeToClipboard,
          ),
          child: QRCodePage(
            qrData: widget.service.wcUri!,
            logoPath: 'assets/walletconnect_logo_white.png',
          ),
        );
      case WalletConnectModalState.walletListShort:
        return WalletConnectModalNavBar(
          key: Key(WalletConnectModalState.walletListShort.name),
          title: const WalletConnectModalNavbarTitle(
            title: 'Connect your wallet',
          ),
          actionWidget: IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: WalletConnectModalTheme.of(context).data.foreground100,
            onPressed: _toQrCode,
          ),
          child: GridList<WalletData>(
            state: GridListState.short,
            provider: widget.service.explorerService,
            viewLongList: _viewLongWalletList,
            onSelect: _onWalletDataSelected,
          ),
        );
      case WalletConnectModalState.walletListLong:
        return WalletConnectModalNavBar(
          key: Key(WalletConnectModalState.walletListLong.name),
          title: WalletConnectModalSearchBar(
            hintText:
                'Search ${platformUtils.instance.getPlatformType().name} wallets',
            onSearch: _updateSearch,
          ),
          onBack: _pop,
          child: GridList<WalletData>(
            // key: ValueKey('${GridListState.long}$_searchQuery'),
            state: GridListState.long,
            provider: widget.service.explorerService,
            viewLongList: _viewLongWalletList,
            onSelect: _onWalletDataSelected,
          ),
        );
      case WalletConnectModalState.qrCodeAndWalletList:
        return WalletConnectModalNavBar(
          key: Key(
            WalletConnectModalState.qrCodeAndWalletList.name,
          ),
          title: const WalletConnectModalNavbarTitle(
            title: 'Connect your wallet',
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              QRCodePage(
                qrData: widget.service.wcUri!,
                logoPath: 'assets/walletconnect_logo_white.png',
              ),
              GridList(
                state: GridListState.extraShort,
                provider: widget.service.explorerService,
                viewLongList: _viewLongWalletList,
                onSelect: _onWalletDataSelected,
              ),
            ],
          ),
        );
      case WalletConnectModalState.chainList:
        return WalletConnectModalNavBar(
          // TODO: Update this to display chains, not wallets
          key: Key(WalletConnectModalState.chainList.name),
          title: const WalletConnectModalNavbarTitle(
            title: 'Select network',
          ),
          child: GridList(
            state: GridListState.extraShort,
            provider: widget.service.explorerService,
            viewLongList: _viewLongWalletList,
            onSelect: _onWalletDataSelected,
          ),
        );
      case WalletConnectModalState.help:
        return WalletConnectModalNavBar(
          key: Key(WalletConnectModalState.help.name),
          title: const WalletConnectModalNavbarTitle(
            title: 'Help',
          ),
          onBack: _pop,
          child: HelpPage(
            getAWallet: () {
              setState(() {
                _stateStack.add(WalletConnectModalState.getAWallet);
              });
            },
          ),
        );
      case WalletConnectModalState.getAWallet:
        return WalletConnectModalNavBar(
          key: Key(WalletConnectModalState.getAWallet.name),
          title: const WalletConnectModalNavbarTitle(
            title: 'Get a wallet',
          ),
          onBack: _pop,
          child: GetWalletPage(
            service: widget.service.explorerService,
          ),
        );
      default:
        return Container();
    }
  }

  Future<void> _onWalletDataSelected(WalletData item) async {
    LoggerUtil.logger.v(
      'Selected ${item.listing.name}. Installed: ${item.installed} Item info: $item.',
    );
    try {
      await urlUtils.instance.navigateDeepLink(
        nativeLink: item.listing.mobile.native,
        universalLink: item.listing.mobile.universal,
        wcURI: widget.service.wcUri!,
      );
    } on LaunchUrlException catch (e) {
      widget.toastService.show(
        ToastMessage(
          type: ToastType.error,
          text: e.message,
        ),
      );
    }
  }

  void _viewLongWalletList() {
    setState(() {
      _stateStack.add(WalletConnectModalState.walletListLong);
    });
  }

  void _pop() {
    setState(() {
      // Remove all of the elements until we get to the help state
      final state = _stateStack.removeLast();

      if (state == WalletConnectModalState.walletListLong) {
        widget.service.explorerService.filterList(query: '');
      }
    });
  }

  void _popUntil(WalletConnectModalState targetState) {
    setState(() {
      // Remove all of the elements until we get to the help state
      WalletConnectModalState removedState = _stateStack.removeLast();
      while (removedState != WalletConnectModalState.help) {
        removedState = _stateStack.removeLast();

        if (removedState == WalletConnectModalState.walletListLong) {
          widget.service.explorerService.filterList(query: '');
        }
      }
    });
  }

  void _toQrCode() {
    setState(() {
      _stateStack.add(WalletConnectModalState.qrCode);
    });
  }

  Future<void> _copyQrCodeToClipboard() async {
    await Clipboard.setData(
      ClipboardData(
        text: widget.service.wcUri!,
      ),
    );
    widget.toastService.show(
      ToastMessage(
        type: ToastType.info,
        text: 'QR Copied',
      ),
    );
  }

  void _updateSearch(String query) {
    widget.service.explorerService.filterList(query: query);
  }
}
