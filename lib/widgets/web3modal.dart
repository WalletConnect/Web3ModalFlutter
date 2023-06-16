import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/listings.dart';
import 'package:web3modal_flutter/pages/get_wallet_page.dart';
import 'package:web3modal_flutter/pages/help_page.dart';
import 'package:web3modal_flutter/services/toast/toast_message.dart';
import 'package:web3modal_flutter/services/toast/toast_service.dart';
import 'package:web3modal_flutter/utils/logger_util.dart';

import 'package:web3modal_flutter/widgets/qr_code_widget.dart';
import 'package:web3modal_flutter/services/web3modal/i_web3modal_service.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/widgets/toast/web3modal_toast_manager.dart';
import 'package:web3modal_flutter/widgets/transition_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_navbar.dart';
import 'package:web3modal_flutter/widgets/web3modal_theme.dart';
import 'package:web3modal_flutter/widgets/toast/web3modal_toast.dart';

class Web3Modal extends StatefulWidget {
  const Web3Modal({
    super.key,
    required this.service,
    this.initialState,
  });

  final IWeb3ModalService service;
  final Web3ModalState? initialState;

  @override
  State<Web3Modal> createState() => _Web3ModalState();
}

class _Web3ModalState extends State<Web3Modal>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  final ToastService _toastService = ToastService();

  // Web3Modal State
  final List<Web3ModalState> _stateStack = [];

  // Wallet List
  List<GridListItemModel> _wallets = [];

  // Connection
  String _qrCode = '';

  // Animations
  // late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.initialState != null) {
      _stateStack.add(widget.initialState!);
    } else {
      final PlatformType pType = Util.getPlatformType();

      // Choose the state based on platform
      if (pType == PlatformType.mobile) {
        _stateStack.add(Web3ModalState.walletListShort);
      } else if (pType == PlatformType.desktop) {
        _stateStack.add(Web3ModalState.qrCodeAndWalletList);
      }
    }

    initialize();
  }

  Future<void> initialize() async {
    // If we aren't connected, connect!
    if (!widget.service.isConnected) {
      LoggerUtil.logger.i(
        'Connecting to WalletConnect, required namespaces: ${widget.service.requiredNamespaces}',
      );
      final ConnectResponse response = await widget.service.web3App!.connect(
        requiredNamespaces: widget.service.requiredNamespaces,
      );

      setState(() {
        _qrCode = response.uri.toString();
      });
    }

    // Fetch the wallet list
    ListingResponse items =
        await widget.service.explorerService.getAllListings();

    List<GridListItemModel> walletList = [];
    for (Listing item in items.listings.values) {
      bool installed = await Util.isInstalled(item.mobile.native ?? '');
      walletList.add(
        GridListItemModel(
          title: item.name,
          description: installed ? 'Installed' : null,
          image: widget.service.explorerService.getWalletImageUrl(
            imageId: item.imageId,
          ),
          onSelect: () async {
            LoggerUtil.logger.v(
              'Selected ${item.name}. Installed: $installed Item info: $item.',
            );
            if (installed) {
              Util.navigateDeepLink(
                universalLink: item.mobile.universal,
                deepLink: item.mobile.native,
                wcURI: _qrCode,
              );
            } else {
              launchUrl(
                Uri.parse(item.mobile.universal!),
              );
            }
          },
          installed: installed,
        ),
      );
      // Sort the installed wallets to the top
      walletList.sort((a, b) {
        if (a.installed == b.installed) {
          return 0;
        } else if (a.installed && !b.installed) {
          return -1;
        } else {
          return 1;
        }
      });
    }

    setState(() {
      _wallets = walletList;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Web3ModalTheme theme = Web3ModalTheme.of(context);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 400,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(
          theme.borderRadius,
        ),
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
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'WalletConnect',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: _stateStack.last == Web3ModalState.help
                          ? const Icon(Icons.help_outlined)
                          : const Icon(Icons.help_outline),
                      onPressed: () {
                        if (_stateStack.contains(Web3ModalState.help)) {
                          _popUntil(Web3ModalState.help);
                        } else {
                          setState(() {
                            _stateStack.add(Web3ModalState.help);
                          });
                        }
                      },
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        widget.service.close();
                      },
                      color: Colors.white,
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
                  theme.borderRadius * 2,
                ),
                topRight: Radius.circular(
                  theme.borderRadius * 2,
                ),
              ),
              color: Colors.black,
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
                  toastService: _toastService,
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
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    switch (_stateStack.last) {
      case Web3ModalState.qrCode:
        return Web3ModalNavBar(
          key: Key(Web3ModalState.qrCode.name),
          title: 'Scan QR Code',
          onBack: _pop,
          actionWidget: IconButton(
            icon: const Icon(Icons.copy_outlined),
            color: Web3ModalTheme.of(context).backgroundColor,
            onPressed: _copyQrCodeToClipboard,
          ),
          child: QRCodePage(
            qrData: _qrCode,
            logoPath: 'assets/walletconnect_logo_white.png',
          ),
        );
      case Web3ModalState.walletListShort:
        return Web3ModalNavBar(
          key: Key(Web3ModalState.walletListShort.name),
          title: 'Connect your wallet',
          actionWidget: IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Web3ModalTheme.of(context).backgroundColor,
            onPressed: _toQrCode,
          ),
          child: GridList(
            key: Key('${GridListState.short}${_wallets.length}'),
            state: GridListState.short,
            items: _wallets,
            viewLongList: _viewLongWalletList,
          ),
        );
      case Web3ModalState.walletListLong:
        return Web3ModalNavBar(
          key: Key(Web3ModalState.walletListLong.name),
          title: 'TODO: Implement Search',
          onBack: _pop,
          child: GridList(
            key: Key('${GridListState.long}${_wallets.length}'),
            state: GridListState.long,
            items: _wallets,
            viewLongList: _viewLongWalletList,
          ),
        );
      case Web3ModalState.qrCodeAndWalletList:
        return Web3ModalNavBar(
          key: Key(
            Web3ModalState.qrCodeAndWalletList.name,
          ),
          title: 'Connect your wallet',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              QRCodePage(
                qrData: _qrCode,
                logoPath: 'assets/walletconnect_logo_white.png',
              ),
              GridList(
                key: Key('${GridListState.extraShort}${_wallets.length}'),
                state: GridListState.extraShort,
                items: _wallets,
                viewLongList: _viewLongWalletList,
              ),
            ],
          ),
        );
      case Web3ModalState.chainList:
        return Web3ModalNavBar(
          // TODO: Update this to display chains, not wallets
          key: Key(Web3ModalState.chainList.name),
          title: 'Select network',
          child: GridList(
            key: Key('${GridListState.extraShort}${_wallets.length}'),
            state: GridListState.extraShort,
            items: _wallets,
            viewLongList: _viewLongWalletList,
          ),
        );
      case Web3ModalState.help:
        return Web3ModalNavBar(
          key: Key(Web3ModalState.help.name),
          title: 'Help',
          onBack: _pop,
          child: HelpPage(
            getAWallet: () {
              setState(() {
                _stateStack.add(Web3ModalState.getAWallet);
              });
            },
          ),
        );
      case Web3ModalState.getAWallet:
        return Web3ModalNavBar(
          key: Key(Web3ModalState.getAWallet.name),
          title: 'Get a wallet',
          onBack: _pop,
          child: GetWalletPage(
            service: widget.service,
            wallets: _wallets
                .where((GridListItemModel w) => !w.installed)
                .take(6)
                .toList(),
          ),
        );
      default:
        return Container();
    }
  }

  void _viewLongWalletList() {
    setState(() {
      _stateStack.add(Web3ModalState.walletListLong);
    });
  }

  void _pop() {
    setState(() {
      // Remove all of the elements until we get to the help state
      _stateStack.removeLast();
    });
  }

  void _popUntil(Web3ModalState targetState) {
    setState(() {
      // Remove all of the elements until we get to the help state
      Web3ModalState removedState = _stateStack.removeLast();
      while (removedState != Web3ModalState.help) {
        removedState = _stateStack.removeLast();
      }
    });
  }

  void _toQrCode() {
    setState(() {
      _stateStack.add(Web3ModalState.qrCode);
    });
  }

  Future<void> _copyQrCodeToClipboard() async {
    await Clipboard.setData(
      ClipboardData(
        text: _qrCode,
      ),
    );
    _toastService.show(
      ToastMessage(
        type: ToastType.info,
        text: 'QR Copied',
      ),
    );
  }
}
