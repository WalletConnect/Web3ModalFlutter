import 'dart:async';

import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/avatars/loading_border.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class ConnectNetworkPage extends StatefulWidget {
  final W3MChainInfo chainInfo;
  const ConnectNetworkPage({
    required this.chainInfo,
  }) : super(key: KeyConstants.connecNetworkPageKey);

  @override
  State<ConnectNetworkPage> createState() => _ConnectNetworkPageState();
}

class _ConnectNetworkPageState extends State<ConnectNetworkPage>
    with WidgetsBindingObserver {
  IW3MService? _service;
  ModalError? errorEvent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service = Web3ModalProvider.of(context).service;
      _service?.onModalError.subscribe(_errorListener);
      _service!.web3App!.onSessionEvent.subscribe(_onSessionEvent);
      _service!.web3App!.core.relayClient.onRelayClientMessage.subscribe(
        _onRelayClientMessage,
      );
      setState(() {});
      Future.delayed(const Duration(milliseconds: 300), () {
        _connect();
      });
    });
  }

  void _connect() {
    errorEvent = null;
    _service!.launchConnectedWallet();
    _service!.requestSwitchToChain(widget.chainInfo);
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_service?.session?.sessionService.isCoinbase == true) {
        if (_service?.selectedChain?.chainId == widget.chainInfo.chainId) {
          widgetStack.instance.pop();
        }
      }
    }
  }

  void _onSessionEvent(SessionEvent? event) async {
    if (!mounted) return;
    if (event?.name == EventsConstants.chainChanged) {
      debugPrint('[$runtimeType] _onSessionEvent $event');
      final chainId = event?.data.toString() ?? '';
      if (W3MChainPresets.chains.containsKey(chainId)) {
        _service?.web3App?.onSessionEvent.unsubscribe(_onSessionEvent);
        widgetStack.instance.pop();
      }
    }
  }

  void _onRelayClientMessage(MessageEvent? event) async {
    if (!mounted) return;
    if (event != null) {
      final payloadString = await _service!.web3App!.core.crypto.decode(
        event.topic,
        event.message,
      );
      if (payloadString == null) return;
      debugPrint('[$runtimeType] payloadString $payloadString');
    }
  }

  void _errorListener(ModalError? event) => setState(() => errorEvent = event);

  @override
  void dispose() {
    _service?.web3App?.core.relayClient.onRelayClientMessage.unsubscribe(
      _onRelayClientMessage,
    );
    _service?.web3App?.onSessionEvent.unsubscribe(_onSessionEvent);
    _service?.onModalError.unsubscribe(_errorListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
      return ContentLoading();
    }
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final isPortrait = ResponsiveData.isPortrait(context);
    final maxWidth = isPortrait
        ? ResponsiveData.maxWidthOf(context)
        : ResponsiveData.maxHeightOf(context) -
            kNavbarHeight -
            (kPadding16 * 2);
    //
    final chainId = widget.chainInfo.chainId;
    final imageId = AssetUtil.getChainIconId(chainId) ?? '';
    final imageUrl = explorerService.instance.getAssetImageUrl(imageId);
    //
    return Web3ModalNavbar(
      title: widget.chainInfo.chainName,
      noClose: true,
      body: SingleChildScrollView(
        scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kPadding16),
        child: Flex(
          direction: isPortrait ? Axis.vertical : Axis.horizontal,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(dimension: 20.0),
                  LoadingBorder(
                    animate: errorEvent == null,
                    isNetwork: true,
                    borderRadius: themeData.radiuses.isSquare()
                        ? 0
                        : themeData.radiuses.radiusM + 4.0,
                    // themeData.radiuses.radiusM + 4.0
                    child: _WalletAvatar(
                      imageUrl: imageUrl,
                      errorConnection: errorEvent is UserRejectedConnection,
                      themeColors: themeColors,
                    ),
                  ),
                  const SizedBox.square(dimension: 20.0),
                  errorEvent != null
                      ? Text(
                          'Switch declined',
                          textAlign: TextAlign.center,
                          style: themeData.textStyles.paragraph500.copyWith(
                            color: themeColors.error100,
                          ),
                        )
                      : Text(
                          'Continue in ${_service?.session?.peer?.metadata.name ?? 'wallet'}',
                          textAlign: TextAlign.center,
                          style: themeData.textStyles.paragraph500.copyWith(
                            color: themeColors.foreground100,
                          ),
                        ),
                  const SizedBox.square(dimension: 8.0),
                  errorEvent != null
                      ? Text(
                          'Switch can be declined by the user or if a previous request is still active',
                          textAlign: TextAlign.center,
                          style: themeData.textStyles.small500.copyWith(
                            color: themeColors.foreground200,
                          ),
                        )
                      : Text(
                          'Accept switch request in your wallet',
                          textAlign: TextAlign.center,
                          style: themeData.textStyles.small500.copyWith(
                            color: themeColors.foreground200,
                          ),
                        ),
                  const SizedBox.square(dimension: kPadding16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletAvatar extends StatelessWidget {
  const _WalletAvatar({
    required this.imageUrl,
    required this.errorConnection,
    required this.themeColors,
  });

  final String imageUrl;
  final bool errorConnection;
  final Web3ModalColors themeColors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        W3MListAvatar(
          imageUrl: imageUrl,
          isNetwork: true,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Visibility(
            visible: errorConnection,
            child: Container(
              decoration: BoxDecoration(
                color: themeColors.background125,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              padding: const EdgeInsets.all(1.0),
              clipBehavior: Clip.antiAlias,
              child: RoundedIcon(
                assetPath: 'assets/icons/close.svg',
                assetColor: themeColors.error100,
                circleColor: themeColors.error100.withOpacity(0.2),
                borderColor: themeColors.background125,
                padding: 4.0,
                size: 24.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
